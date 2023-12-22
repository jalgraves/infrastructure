# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  workspaces = {
    admin-aws-iam-identity-provider = {
      env         = "admin"
      region      = "us-east-1"
      region_code = "use1"
    }
  }
  configs = local.workspaces[terraform.workspace]
}
