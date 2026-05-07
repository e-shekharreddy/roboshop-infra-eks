variable "project" {
  type =string
  default = "roboshop"
}

variable "environment" {
  type =string
  default = "dev"
}

variable "sg_name" {
  type =string
  default = "mongodb"
}

variable "sg_names" {
   type = list 
   default = [
      # Database
      "mongodb", "redis", "mysql", "rabbitmq",


      # Frontend alb
      "ingress_alb",

      # Bastion
      "bastion",

      # OpenVpn
      "openvpn",

      # EKS cluster
      "eks_control_plane",
      "eks_node",
      
      "jenkins",
      "jenkins_agent",
      
      # "sonar"

   ]
}