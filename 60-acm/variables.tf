
variable "project" {
  type = string
  default = "roboshop"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "zone_id" {
  default = "Z0778804XVQJM2KVD12A"
}

variable "domain_name" { 
  default = "tsmvr.fun"
}