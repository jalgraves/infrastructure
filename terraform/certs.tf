resource "aws_acm_certificate" "ziggys_cert" {
  domain_name       = "*.ziggyscoffeebar.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "ziggys_cert" {
  certificate_arn         = aws_acm_certificate.ziggys_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}