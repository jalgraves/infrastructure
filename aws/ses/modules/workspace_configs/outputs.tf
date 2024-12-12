# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  workspaces = {
    production-aws-ses-use1 = local.production-aws-ses-use1
  }
}

output "values" {
  description = "These are the inputs that will be used to create the resources in the root `iam/` directory."
  value       = local.workspaces[var.workspace]
}
