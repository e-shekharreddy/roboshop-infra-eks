terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.35.1" # terraform aws provider version
    }
  }
  backend "s3" {
    bucket         = "remote-state-esr-dev"
    key            = "terraform-eks-rds"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
}
}

provider "aws" {
  region = "us-east-1"
}

