provider "aws" {
  profile = "beantown"
  region  = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
}

terraform {
  backend "s3" {
    bucket         = "jal-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "jal-terraform-state-lock"
    encrypt        = true
  }
}

module "jke_cluster" {
  source = "../../../modules/services/jke-cluster"
}
