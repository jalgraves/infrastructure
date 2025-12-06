# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

variable "workspace" {}

locals {
  workspaces = {
    production-use1-secrets-manager = local.production-use1-secrets-manager
  }
}

output "values" {
  value = local.workspaces[var.workspace]
}
