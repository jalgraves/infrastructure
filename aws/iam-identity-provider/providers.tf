# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    # Provider versions are pinned to avoid unexpected upgrades
    aws = {
      source  = "hashicorp/aws"
      version = "5.24.0"
    }
  }
  cloud {
    organization = "jalgraves"
    workspaces {
      tags = ["aws", "iam-identity-provider"]
    }
  }
}

provider "aws" {
  region     = local.configs.region
  access_key = "AKIARUG753VYUZM7HW4I"
  secret_key = "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"
  default_tags {
    tags = {
      Environment        = local.configs.env
      Provisioner        = "terraform"
      RegionCode         = local.configs.region_code
      TerraformWorkspace = terraform.workspace
    }
  }
}
