# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-use1-cdn = {
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"

    sites = {
      beantownpub = {
        domain      = "beantownpub.com"
        bucket_name = "beantownpub-production-use1-static-site"
      }
      circleback = {
        domain      = "circlebackkitchenandbar.com"
        bucket_name = "circleback-production-use1-static-site"
      }
      drdavisicecream = {
        domain      = "drdavisicecream.com"
        bucket_name = "drdavisicecream-production-use1-static-site"
      }
      nautoriouscharters = {
        domain      = "nautoriouscharters.com"
        bucket_name = "nautoriouscharters-production-use1-static-site"
      }
      thehubpub = {
        domain      = "thehubpub.com"
        bucket_name = "thehubpub-production-use1-static-site"
      }
      wavelengths = {
        domain      = "wavelengths-brookline.com"
        bucket_name = "wavelengths-production-use1-static-site"
      }
    }
  }
}
