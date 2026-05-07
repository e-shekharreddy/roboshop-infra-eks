resource "aws_instance" "jenkins" {
  ami           = local.ami_id
  instance_type = "t3.small"
  subnet_id = local.public_subnet_id
  vpc_security_group_ids = [local.jenkins_sg_id]
  user_data = file("jenkins.sh")

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-jenkins"
    },
    local.common_tags
  )
}


resource "aws_instance" "jenkins_agent" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.public_subnet_id
  vpc_security_group_ids = [local.jenkins_sg_id]
  user_data = file("jenkins-agent.sh")

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    tags = merge(
      {
          Name = "${var.project}-${var.environment}-jenkins-agent"
      },
    local.common_tags
    )
  }

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-jenkins-agent"
    },
    local.common_tags
  )
}

# resource "aws_instance" "sonarqube" {
#   count = var.sonar ? 1 : 0
#   ami           = local.sonar_ami_id
#   instance_type = "t3.large"
#   vpc_security_group_ids = [local.sonar_sg_id]
#   subnet_id = local.public_subnet_id #replace your Subnet in default VPC
#   key_name = "daws-88s"
#   # need more for terraform
#   root_block_device {
#     volume_size = 20
#     volume_type = "gp3" # or "gp2", depending on your preference
#   }
#   tags = merge(
#     local.common_tags,
#     {
#         Name = "${var.project}-${var.environment}-sonar"
#     }
#   )
# }