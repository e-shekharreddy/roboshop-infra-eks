locals {
  cluster_name  = "${var.project}-${var.environment}"
  oidc_provider = data.aws_iam_openid_connect_provider.this

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }
}