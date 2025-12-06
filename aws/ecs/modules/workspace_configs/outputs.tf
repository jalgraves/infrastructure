variable "workspace" {}

locals {
  workspaces = {
    production-use1-ecs = local.production-use1-ecs
  }
}

output "values" {
  value = local.workspaces[var.workspace]
}
