# fetch the EKS cluster to get the OIDC issuer URL
data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

# fetch the OIDC provider created by the EKS module
data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_caller_identity" "current" {}