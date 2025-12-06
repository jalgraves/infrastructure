# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.24.0"
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
