# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.22.1"
    }
    ns1 = {
      source  = "ns1-terraform/ns1"
      version = "~> 2.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = local.configs.region
  default_tags {
    tags = {
      Environment        = local.configs.environment
      Provisioner        = "terraform"
      RegionCode         = local.configs.region_code
      TerraformWorkspace = terraform.workspace
    }
  }
}

provider "ns1" {
  apikey = var.ns1_api_key
}
