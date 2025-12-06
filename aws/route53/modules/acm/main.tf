# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
  tags = {
    Name = var.name
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "this" {
  for_each = var.ns1_hosted_domain ? {} : {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = var.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count                   = var.ns1_hosted_domain ? 0 : 1
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for domain in var.subject_alternative_names : aws_route53_record.this[domain].fqdn]
}

module "ns1" {
  # source  = "app.terraform.io/beantown/ns1/aws"
  # version = "0.1.1"
  source = "git::https://github.com/beantownpub/terraform-aws-ns1?ref=f5022ad6c59d4448b9165c30be489c8783619f7e"

  for_each = var.ns1_hosted_domain ? {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      domain       = dvo.domain_name
      record_name  = dvo.resource_record_name
      record_value = dvo.resource_record_value
    }
  } : {}
  ns1_api_key  = var.ns1_api_key
  cname_record = each.value.record_name
  cname_target = each.value.record_value
  dns_zone     = each.value.domain
}
