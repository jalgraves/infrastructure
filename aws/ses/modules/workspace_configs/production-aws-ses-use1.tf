# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-aws-ses-use1 = {
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"
    identities = {
      beantownpub = {
        domain_name = "beantownpub.com"
      }
    }
  }
}
