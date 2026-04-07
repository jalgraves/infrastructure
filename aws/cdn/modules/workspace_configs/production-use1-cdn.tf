# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-use1-cdn = {
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"

    sites = {
      circleback = {
        domain      = "circlebackkitchenandbar.com"
        bucket_name = "circleback-production-use1-static-site"
      }
    }
  }
}
