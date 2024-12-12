# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  development-aws-route53-use1 = {
    acm = {
      certificates = {
        "development.use1.jalgraves.com" = {
          label                     = "jalgraves-development-use1"
          ns1_hosted_domain         = false
          subject_alternative_names = ["*.development.use1.jalgraves.com"]
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
        "development.use1.jalgraves.com" = {
          records = []
        }
      }
    }
    environment = "development"
    region      = "us-east-1"
    region_code = "use1"
  }
}
