data "aws_ami" "joindevops" {
  most_recent      = true
  owners           = ["973714476881"]

  filter {
    name   = "name"
    values = ["Redhat-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# data "aws_ami" "sonarqube" {
#   most_recent = true
#   owners      = ["679593333241"] # Solve DevOps

#   filter {
#     name   = "name"
#     values = ["SolveDevOps-SonarQube-Server-Ubuntu24.04-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }

data "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "jenkins_sg_id" {
    name = "/${var.project}/${var.environment}/jenkins_sg_id"
}

data "aws_ssm_parameter" "jenkins_agent_sg_id" {
    name = "/${var.project}/${var.environment}/jenkins_agent_sg_id"
}

# data "aws_ssm_parameter" "sonar_sg_id" {
#     name = "/${var.project}/${var.environment}/sonar_sg_id"
# }