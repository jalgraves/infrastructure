# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-use1-lambda = {
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"

    contact_form = {
      runtime            = "python3.12"
      timeout            = 10
      memory_size        = 128
      log_retention_days = 7

      # Origins allowed to call the Function URL from the browser. These are the
      # CloudFront frontends served out of the `cdn/` stack.
      allowed_origins = [
        "https://nautoriouscharters.com",
        "https://www.nautoriouscharters.com",
        "http://localhost:5173"
      ]

      # Per-site email routing. The frontend form must send a "site" field that
      # matches one of these keys. Each `sender` domain must be a verified SES
      # identity (see the `ses/` stack).
      sites = {
        nautoriouscharters = {
          sender     = "no-reply@nautoriouscharters.com"
          recipients = ["nautoriousyachtcharters@gmail.com"]
          subject    = "New contact form submission - Nautorious Yacht Charters"
        }
      }
    }
  }
}
