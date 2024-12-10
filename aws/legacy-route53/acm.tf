# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_acm_certificate" "env" {
  domain_name               = "${local.legacy_configs.region_code}.${local.legacy_configs.env}.aws.${local.legacy_configs.org}.com"
  subject_alternative_names = ["*.${local.legacy_configs.region_code}.${local.legacy_configs.env}.aws.${local.legacy_configs.org}.com"]
  validation_method         = "DNS"
  tags = {
    Name = "${local.legacy_configs.region_code}-${local.legacy_configs.env}.${local.legacy_configs.org}.env-certificate"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_env" {
  for_each = {
    for dvo in aws_acm_certificate.env.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.region.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "env" {
  certificate_arn         = aws_acm_certificate.env.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_env : record.fqdn]
}

resource "aws_acm_certificate" "client_domains" {
  for_each                  = local.legacy_configs.env == "development" ? toset(var.client_domains) : []
  domain_name               = each.value
  subject_alternative_names = ["*.${each.value}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  dns_validation = local.legacy_configs.env == "develpment" ? flatten([
    for domain in var.client_domains : [
      for record_name, record_value in aws_acm_certificate.client_domains[domain].domain_validation_options[*] : {
        domain       = record_value.domain_name
        record_name  = record_value.resource_record_name
        record_value = record_value.resource_record_value
      }
    ]
  ]) : []
}

module "ns1" {
  source  = "app.terraform.io/beantown/ns1/aws"
  version = "0.1.1"

  for_each = {
    for domain in local.dns_validation : domain.domain => domain
  }
  ns1_api_key  = var.ns1_api_key
  cname_record = each.value.record_name
  cname_target = each.value.record_value
  dns_zone     = each.value.domain
}
