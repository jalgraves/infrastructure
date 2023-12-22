# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

terraform {
  required_version = ">= 1.4.0"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.51.0"
    }
  }
  cloud {
    organization = "jalgraves"
    workspaces {
      tags = ["aws", "tfc"]
    }
  }
}

provider "tfe" {
  token = var.tfc_token
}
