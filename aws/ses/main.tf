# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_sesv2_email_identity" "this" {
  for_each = {
    for identity_name, identity in local.configs.identities : identity_name => identity
  }
  email_identity = each.value.domain_name
}

locals {
  dns_records = {
    for item in flatten([
      for identity_name, identity in aws_sesv2_email_identity.this : [
        for token in identity.dkim_signing_attributes[0].tokens : {
          domain       = identity.email_identity
          record_name  = "${token}._domainkey.${identity.email_identity}"
          record_value = "${token}.dkim.amazonses.com"
        }
      ]
    ])
    : "${item.domain}:${item.record_name}" => item
  }
}
output "dkim" {
  value = {
    dns_records = local.dns_records
  }
}

module "ns1" {
  source  = "app.terraform.io/beantown/ns1/aws"
  version = "0.1.1"

  for_each = {
    for item in flatten([
      for identity_name, identity in aws_sesv2_email_identity.this : [
        for token in identity.dkim_signing_attributes[0].tokens : {
          domain       = identity.email_identity
          record_name  = "${token}._domainkey.${identity.email_identity}"
          record_value = "${token}.dkim.amazonses.com"
        }
      ]
    ])
    : "${item.domain}:${item.record_name}" => item
  }
  ns1_api_key  = var.ns1_api_key
  cname_record = each.value.record_name
  cname_target = each.value.record_value
  dns_zone     = each.value.domain
}
