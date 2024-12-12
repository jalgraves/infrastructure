# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "acm" {
  # Module for creating ACM certificates
  source = "./modules/acm"

  for_each = {
    for cert_name, cert in local.configs.acm.certificates : cert_name => cert
  }

  domain_name               = each.key
  name                      = each.value.label
  zone_id                   = each.value.ns1_hosted_domain ? null : aws_route53_zone.this[each.key].id
  subject_alternative_names = each.value.subject_alternative_names
  ns1_api_key               = var.ns1_api_key
  ns1_hosted_domain         = each.value.ns1_hosted_domain
  depends_on = [
    aws_route53_zone.this
  ]
}
