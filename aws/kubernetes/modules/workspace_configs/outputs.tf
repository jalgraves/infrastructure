# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "workspace" {}

locals {
  workspaces = {
    development-aws-kubernetes-use2 = local.development-aws-kubernetes-use2
    #development-aws-kubernetes-use1 = local.development-aws-kubernetes-use1
    #production-aws-kubernetes-use1  = local.production-aws-kubernetes-use1
  }
}

output "values" {
  value = local.workspaces[var.workspace]
}
