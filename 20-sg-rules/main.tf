resource "aws_security_group_rule" "bastion_internet" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  #   cidr_blocks       = ["0.0.0.0/0"]
  cidr_blocks       = [local.my_ip]
  # which security group you are creating this for "bastion"
  security_group_id = local.bastion_sg_id
}

resource "aws_security_group_rule" "mongodb_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # where traffic is comming from
  source_security_group_id = local.bastion_sg_id
  # dest or accepting
  security_group_id = local.mongodb_sg_id
}

resource "aws_security_group_rule" "redis_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # where traffic is comming from
  source_security_group_id = local.bastion_sg_id
  # dest or accepting
  security_group_id = local.redis_sg_id
}


resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  # where traffic is comming from
  source_security_group_id = local.bastion_sg_id
  # dest or accepting
  security_group_id = local.mysql_sg_id
}
resource "aws_security_group_rule" "mysql_eks_node" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  # where traffic is comming from
  source_security_group_id = local.eks_node_sg_id
  # dest or accepting
  security_group_id = local.mysql_sg_id
}
resource "aws_security_group_rule" "rabbitmq_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # where traffic is comming from
  source_security_group_id = local.bastion_sg_id
  # dest or accepting
  security_group_id = local.rabbitmq_sg_id
}

resource "aws_security_group_rule" "ingress_alb_public" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # where traffic is comming from
  cidr_blocks = ["0.0.0.0/0"]
  # dest or accepting one
  security_group_id = local.ingress_alb_sg_id
}
resource "aws_security_group_rule" "eks_node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # where traffic is comming from
  source_security_group_id = local.bastion_sg_id
  # dest or accepting
  security_group_id = local.eks_node_sg_id
}


# Open VPN
resource "aws_security_group_rule" "openvpn_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # where traffic is comming from
  cidr_blocks = ["0.0.0.0/0"]
  # dest or accepting one
  security_group_id = local.openvpn_sg_id
}
# Admin UI
resource "aws_security_group_rule" "openvpn_public_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  # where traffic is comming from
  cidr_blocks = ["0.0.0.0/0"]
  # dest or accepting one
  security_group_id = local.openvpn_sg_id
}
resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # where traffic is comming from
  source_security_group_id = local.bastion_sg_id
  # dest or accepting
  security_group_id = local.eks_control_plane_sg_id
}

resource "aws_security_group_rule" "eks_control_plane_eks_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all traffic
  # where traffic is comming from
  source_security_group_id = local.eks_node_sg_id
  # dest or accepting
  security_group_id = local.eks_control_plane_sg_id
}
resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all traffic
  # where traffic is comming from
  source_security_group_id = local.eks_control_plane_sg_id
  # dest or accepting
  security_group_id = local.eks_node_sg_id
}

resource "aws_security_group_rule" "eks_node_vpc_cidr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all traffic
  # VPC cidr
  cidr_blocks = ["10.0.0.0/16"]
  # dest or accepting
  security_group_id = local.eks_node_sg_id
}