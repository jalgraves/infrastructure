# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-aws-route53-use1 = {
    acm = {
      certificates = {
        "production.use1.aws.beantownpub.com" = {
          label                     = "production-use1"
          subject_alternative_names = ["*.production.use1.aws.beantownpub.com"]
        }
      }
    }
    dns = {
      default_ttl = "300"
      zones = {
        "jalgraves.com" = {
          records = []
        }
        "use1.jalgraves.com" = {
          records = []
        }
        "production.use1.jalgraves.com" = {
          records = []
        }
      }
    }
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"
  }
}
