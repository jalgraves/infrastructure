# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    # Provider versions are pinned to avoid unexpected upgrades
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
  cloud {
    organization = "jalgraves"
    workspaces {
      tags = ["aws", "route53"]
    }
  }
}

provider "aws" {
  region = local.configs.region
  default_tags {
    tags = {
      Environment        = local.configs.env
      Provisioner        = "terraform"
      RegionCode         = local.configs.region_code
      TerraformWorkspace = terraform.workspace
    }
  }
}
