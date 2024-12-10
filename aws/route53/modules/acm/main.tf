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
  for_each = {
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
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for domain in var.subject_alternative_names : aws_route53_record.this[domain].fqdn]
}
