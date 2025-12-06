variable "workspace" {}

locals {
  workspaces = {
    production-use1-ecr = local.production-use1-ecr
  }
}

output "values" {
  value = local.workspaces[var.workspace]
}
