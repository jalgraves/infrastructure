# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# ACM certificates for CloudFront distributions.
# CloudFront requires certificates in us-east-1, which is where this workspace runs.

resource "aws_acm_certificate" "this" {
  for_each = local.configs.sites

  domain_name               = each.value.domain
  subject_alternative_names = ["*.${each.value.domain}"]
  validation_method         = "DNS"

  tags = {
    Name = each.key
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "ns1_validation" {
  source = "git::https://github.com/beantownpub/terraform-aws-ns1?ref=f5022ad6c59d4448b9165c30be489c8783619f7e"

  for_each = {
    for item in flatten([
      for site_name, site in local.configs.sites : [
        for dvo in aws_acm_certificate.this[site_name].domain_validation_options : {
          site_name    = site_name
          domain       = dvo.domain_name
          record_name  = dvo.resource_record_name
          record_value = dvo.resource_record_value
        }
      ]
    ]) : "${item.site_name}:${item.domain}" => item
  }

  ns1_api_key  = var.ns1_api_key
  cname_record = each.value.record_name
  cname_target = each.value.record_value
  dns_zone     = each.value.domain
}
