# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  workspaces = {
    development-aws-iam-use1 = local.development-aws-iam-use1
    production-aws-iam-use1  = local.production-aws-iam-use1
  }
}

output "values" {
  description = "These are the inputs that will be used to create the resources in the root `iam/` directory."
  value       = local.workspaces[var.workspace]
}
