# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-use1-ses = {
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"
    identities = {
      nautoriouscharters = {
        domain_name = "nautoriouscharters.com"
      }
    }
  }
}
