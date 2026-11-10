# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  organizational_units = {
    infrastructure = {}
    security       = {}
  }
  accounts = {
    production = {
      email               = var.production_account_email
      organizational_unit = "infrastructure"
    }
  }
}
