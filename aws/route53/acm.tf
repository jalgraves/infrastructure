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
  zone_id                   = aws_route53_zone.this[each.key].id
  subject_alternative_names = each.value.subject_alternative_names
  depends_on = [
    aws_route53_zone.this
  ]
}
