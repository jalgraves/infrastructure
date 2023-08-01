# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "acm" {
  value = {
    certificates = {
      env = {
        arn = aws_acm_certificate.env.arn
      }
    }
  }
}

output "route53" {
  value = {
    zones = {
      aws    = data.aws_route53_zone.aws
      env    = aws_route53_zone.env
      region = aws_route53_zone.region
    }
    records = {
      env    = aws_route53_record.env
      region = aws_route53_record.region
    }
  }
}
