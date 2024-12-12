# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-aws-route53-use1 = {
    acm = {
      certificates = {
        "production.use1.aws.beantownpub.com" = {
          label                     = "production-use1"
          ns1_hosted_domain         = false
          subject_alternative_names = ["*.production.use1.aws.beantownpub.com"]
        }
        "beantownpub.com" = {
          label                     = "beantownpub-use1"
          ns1_hosted_domain         = true
          subject_alternative_names = ["*.beantownpub.com"]
        }
        "thehubpub.com" = {
          label                     = "thehubpub-use1"
          ns1_hosted_domain         = true
          subject_alternative_names = ["*.thehubpub.com"]
        }
        "wavelengths-brookline.com" = {
          label                     = "wavelengths-brookline-use1"
          ns1_hosted_domain         = true
          subject_alternative_names = ["*.wavelengths-brookline.com"]
        }
        "drdavisicecream.com" = {
          label                     = "drdavisicecream-use1"
          ns1_hosted_domain         = true
          subject_alternative_names = ["*.drdavisicecream.com"]
        }
      }
    }
    dns = {
      default_ttl = "300"
      zones = {
        "aws.beantownpub.com" = {
          parent_zone = "aws.beantownpub.com"
          records     = []
        }
        "use1.aws.beantownpub.com" = {
          records = []
        }
        "production.use1.aws.beantownpub.com" = {
          records = []
        }
      }
    }
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"
  }
}
