# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    # Provider versions are pinned to avoid unexpected upgrades
    aws = {
      source  = "hashicorp/aws"
      version = "6.22.1"
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
