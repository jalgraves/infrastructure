variable "vpc_id" {}
variable "name" {}
variable "jke_type" {}
variable "instance_type" {}
variable "security_group_id" {}
variable "alb_security_group_id" {}
variable "subnet_id" {}
variable "block_size" {}
variable "key_name" { default = "beantown_aws" }

data "aws_vpc" "prod" {
  id = var.vpc_id
}

data "aws_security_group" "jal_default" {
  id = var.security_group_id
}

data "aws_security_group" "alb_security_group" {
  id = var.alb_security_group_id
}

resource "aws_instance" "jke_node" {
  availability_zone      = var.node_azs[var.name]
  ami                    = lookup(var.aws_amis, var.aws_region)
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [data.aws_security_group.jal_default.id, data.aws_security_group.alb_security_group.id]
  subnet_id              = var.subnet_id
  user_data              = file("files/bootstrap_docker.sh") 
  root_block_device {
    volume_type = "gp2"
    volume_size = var.block_size
  }

  tags = {
    Name         = var.name
    role         = "jke"
    jke-type     = var.jke_type
    region       = var.aws_region
    provisioner  = "terraform"
  }
}