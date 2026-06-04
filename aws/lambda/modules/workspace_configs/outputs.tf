# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  workspaces = {
    production-use1-lambda = local.production-use1-lambda
  }
}

output "values" {
  description = "These are the inputs that will be used to create the resources in the root `lambda/` directory."
  value       = local.workspaces[var.workspace]
}
