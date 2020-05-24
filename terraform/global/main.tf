provider "aws" {
  profile = "beantown"
  region  = "us-east-2"
  shared_credentials_file = "~/.aws/credentials"
}

terraform {
  backend "s3" {
    bucket         = "jal-terraform-state"
    key            = "global/network/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "jal-terraform-state-lock"
    encrypt        = true
  }
}

resource "aws_eip" "nat" {
    vpc = true
}

module "network" {
  source = "../modules/network"
}

module "rancher" {
  source            = "../modules/rancher"
  vpc_id            = module.network.prod_vpc_id
  subnet_id         = module.network.jalnet_public_subnet_id
  security_group_id = module.network.jal_sg_id
  block_size            = "15"
}

module "alb" {
  source            = "../modules/alb"
  aws_region        = "us-east-2"
  vpc_id            = module.network.prod_vpc_id
  security_group_id = module.network.alb_sg_id
  instance_id       = module.rancher.instance_id
  subnets           = module.network.subnet_ids
}

module "jke-control" {
  source                = "../modules/k8s"
  name                  = "jke-control01"
  jke_type              = "control"
  vpc_id                = module.network.prod_vpc_id
  instance_type         = "t3.small"
  security_group_id     = module.network.jal_sg_id
  alb_security_group_id = module.network.alb_sg_id
  subnet_id             = module.network.jalnet_private_subnet_2b_id
  block_size            = "15"
}

module "jke-worker" {
  source                = "../modules/k8s"
  name                  = "jke-worker01"
  jke_type              = "worker"
  vpc_id                = module.network.prod_vpc_id
  instance_type         = "t3.medium"
  security_group_id     = module.network.jal_sg_id
  alb_security_group_id = module.network.alb_sg_id
  subnet_id             = module.network.jalnet_private_subnet_2b_id
  block_size            = "25"
}