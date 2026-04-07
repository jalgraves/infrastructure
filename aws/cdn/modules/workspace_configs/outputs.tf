# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "workspace" {
  type = string
}

locals {
  workspaces = {
    production-use1-cdn = local.production-use1-cdn
  }
}

output "values" {
  description = "Workspace-specific configuration values for the CDN service."
  value       = local.workspaces[var.workspace]
}
