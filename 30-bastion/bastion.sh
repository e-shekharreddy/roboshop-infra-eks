#!/bin/bash

growpart /dev/nvme0n1 4
lvextend -L +30G /dev/RootVG/varVol
xfs_growfs /var

# Docker
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && rm eksctl_Linux_amd64.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl

# kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.35.2/2026-02-27/bin/linux/amd64/kubectl
chmod +x ./kubectl
cp kubectl /usr/local/bin/kubectl

# kubens (part of kubectx)
curl -sLo /usr/local/bin/kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
chmod +x /usr/local/bin/kubens

# k9s
curl -sLO "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"
tar -xzf k9s_Linux_amd64.tar.gz -C /tmp && rm k9s_Linux_amd64.tar.gz
sudo install -m 0755 /tmp/k9s /usr/local/bin && rm /tmp/k9s

# helm3
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


