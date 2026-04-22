# Setup

Login to the bastion host and configure AWS credentials:
```bash
aws configure
```

Update kubeconfig to connect to the EKS cluster:
```bash
aws eks update-kubeconfig --region us-east-1 --name roboshop-dev
```

Check nodes are ready:
```bash
kubectl get nodes
```

## Setup DB

Our EKS module already added EBS and EFS roles. The below setup is required before installing the databases.

#### Install EBS CSI Driver

First, add the Helm repository:
```bash
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
```

Install the latest release of the driver:
```bash
helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver
```

#### Create Namespace and Storage Class

All manifests are inside the 60-eks/app folder.

Create the roboshop namespace:
```bash
kubectl apply -f namespace.yaml
```

Create storage class:
```bash
kubectl apply -f ebs-sc.yaml
```

#### Create Databases

These are StatefulSets with a headless service and a ClusterIP service:
```bash
kubectl apply -f mongodb/manifest.yaml
kubectl apply -f redis/manifest.yaml
kubectl apply -f rabbitmq/manifest.yaml
```

We are using MySQL as an RDS service. Make sure it is created, data is loaded through the bastion, and an SG rule exists in RDS to accept traffic from the EKS nodes.

Transfer the database files to bastion and then load them:
```bash
mysql -h <end-point> -u root -PRoboShop#123
```

## Stateless Apps

All stateless backend and frontend apps are Helm charts. Run from inside each chart folder:
```bash
helm upgrade --install catalogue .
helm upgrade --install user .
helm upgrade --install cart .
helm upgrade --install shipping .
helm upgrade --install payment .
```

## Exposing App to Internet

1. Ingress controller
2. LoadBalancer controller
3. Gateway API

We have k8-ingress for the 3 approaches. The first approach is already obsolete, but you should understand the difference between each.

### Ingress Controller Setup

OIDC provider is already part of EKS cluster creation.

#### Create IAM Policy

```bash
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.2.1/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```

#### Create Service Account

```bash
eksctl create iamserviceaccount \
--cluster=roboshop \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region us-east-1 \
--approve
```

#### Install Controller via Helm

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=roboshop \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

#### Install Frontend Application

```bash
helm upgrade --install frontend .
```

#### Cleanup

Once everything is tested, clean up.

Delete ingress:
```bash
kubectl delete ingress frontend -n roboshop
```

Uninstall load balancer controller:
```bash
helm uninstall aws-load-balancer-controller -n kube-system
```

### Gateway Setup

Gateway API is the modern replacement for Ingress. It separates concerns — the platform team manages the Gateway (ALB), and the app team manages the routes. This gives better flexibility and cleaner configuration.

#### Install Gateway API CRDs

CRDs teach Kubernetes about new resource types. Without them, Kubernetes has no idea what a `Gateway` or `HTTPRoute` is.

```bash
# Must be v1.5.0 — earlier versions missing TLSRoute v1 which LBC v3.x requires
kubectl apply --server-side=true \
  -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml

# Verify — should see 8+ CRDs
kubectl get crd | grep gateway
```

Expected output:
```
gatewayclasses.gateway.networking.k8s.io
gateways.gateway.networking.k8s.io
httproutes.gateway.networking.k8s.io
tlsroutes.gateway.networking.k8s.io   ← must be v1 not v1alpha2
```

#### Install AWS-specific CRDs

These are extra CRDs that only exist for AWS — `LoadBalancerConfiguration`, `TargetGroupConfiguration`, `ListenerRuleConfiguration`.

```bash
kubectl apply \
  -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/config/crd/gateway/gateway-crds.yaml

# Verify TLSRoute is v1 (required by LBC v3.x)
kubectl get crd tlsroutes.gateway.networking.k8s.io -o yaml | grep "name: v1"
# Must show: name: v1
```

IAM Policy and Service Account already exist from the Ingress setup above.

#### Install AWS Load Balancer Controller

The Gateway API requires the ALBGatewayAPI and NLBGatewayAPI feature gates to be enabled. We also pass the VPC ID so the controller can discover the VPC correctly.

```bash
VPC_ID=$(aws ssm get-parameter --name /roboshop/dev/vpc_id \
  --region us-east-1 --query Parameter.Value --output text)

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=roboshop-dev \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=$VPC_ID \
  --set controllerConfig.featureGates.ALBGatewayAPI=true \
  --set controllerConfig.featureGates.NLBGatewayAPI=true

kubectl rollout status deployment aws-load-balancer-controller -n kube-system
kubectl get pods -n kube-system | grep aws-load-balancer
```

#### Create GatewayClass

One per cluster. Tells Kubernetes that anything referencing `roboshop-aws-alb` should be handled by the AWS LBC.

```bash
kubectl apply -f gatewayclass.yaml

# Wait for ACCEPTED=True before moving on
kubectl get gatewayclass roboshop-aws-alb
```

#### Create LoadBalancerConfiguration

ALB-level settings — scheme (internet-facing vs internal) and IP type. In LBC v3.x, annotations on the Gateway are ignored, so all ALB settings must go here.

```bash
kubectl apply -f loadbalancerconfiguration.yaml
```

#### Create Gateway

This actually creates the ALB in AWS. Takes 1-2 minutes. The ADDRESS field shows the ALB DNS once it is ready.

```bash
kubectl apply -f gateway.yaml

# Watch until PROGRAMMED=True and ADDRESS appears
kubectl get gateway -w
```

#### Expose the Frontend

Creates the TargetGroupConfiguration (registers pod IPs in the ALB target group) and the HTTPRoute (routes traffic from the domain to the frontend service).

```bash
kubectl apply -f frontend.yaml
```