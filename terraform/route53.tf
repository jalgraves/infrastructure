data "aws_route53_zone" "ziggys_zone" {
  name         = "ziggyscoffeebar.com."
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.ziggys_cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.ziggys_cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.ziggys_zone.id
  records = [aws_acm_certificate.ziggys_cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}
