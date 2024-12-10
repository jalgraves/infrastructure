# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "acm" {
  value = {
    certificates = {
      env = {
        arn = aws_acm_certificate.env.arn
      }
      client_domain_arns = local.configs.env == "development" ? [
        for domain in var.client_domains : aws_acm_certificate.client_domains[domain].arn
      ] : []
      client_domains = local.configs.env == "development" ? {
        for domain in var.client_domains : domain => {
          arn = aws_acm_certificate.client_domains[domain].arn
        }
      } : {}
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
