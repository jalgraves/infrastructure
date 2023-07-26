# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "workspace" {}

locals {
  workspaces = {
    development-aws-vpc-use1 = local.development-aws-vpc-use1
    production-aws-vpc-use1  = local.production-aws-vpc-use1
  }
}

output "values" {
  value = local.workspaces[var.workspace]
}
