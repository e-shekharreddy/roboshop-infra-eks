module "eks" {
  source = "../../terraform-aws-eks"

  project     = var.project
  environment = var.environment

  cluster_version            = var.eks_version
  vpc_id                     = local.vpc_id
  private_subnet_ids         = local.private_subnet_ids
  cluster_security_group_ids = [local.eks_control_plane_sg_id]
  node_security_group_ids    = [local.eks_node_sg_id]

  eks_managed_node_groups = {
    blue = {
      create             = var.enable_blue
      kubernetes_version = var.eks_nodegroup_blue_version
      instance_types     = ["c3.large", "c4.large", "c5.large", "c5d.large", "c5n.large", "c5a.large"]
      capacity_type  = "SPOT"
      min_size       = 2
      max_size       = 10
      desired_size   = 2
      labels         = { nodegroup = "blue" }
      iam_role_additional_policies = {
        amazonEBS = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        amazonEFS = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      }
    }

    green = {
      create             = var.enable_green
      kubernetes_version = var.eks_nodegroup_green_version
      instance_types     = ["c3.large", "c4.large", "c5.large", "c5d.large", "c5n.large", "c5a.large"]
      capacity_type      = "SPOT"
      min_size           = 2
      max_size           = 10
      desired_size       = 2
      labels             = { nodegroup = "green" }
      iam_role_additional_policies = {
        amazonEBS = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        amazonEFS = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      }
    }
  }

  cluster_tags = local.common_tags
}
