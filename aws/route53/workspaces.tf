# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  workspaces = {
    development-aws-route53-use2 = {
      env         = "development"
      org         = "beantownpub"
      region      = "us-east-2"
      region_code = "use2"
    }
    production-aws-route53-use1 = {
      env         = "production"
      org         = "beantownpub"
      region      = "us-east-1"
      region_code = "use1"
    }
    production-aws-route53-use2 = {
      env         = "production"
      org         = "beantownpub"
      region      = "us-east-2"
      region_code = "use2"
    }
  }
  configs = local.workspaces[terraform.workspace]
}
