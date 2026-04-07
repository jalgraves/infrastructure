# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# DNS records pointing each site's domain to its CloudFront distribution.
# Domains are hosted on NS1, so we use the NS1 provider to create the records.

# Apex domain ALIAS record → CloudFront distribution
resource "ns1_record" "apex" {
  for_each = local.configs.sites

  zone   = each.value.domain
  domain = each.value.domain
  type   = "ALIAS"
  ttl    = 300

  answers {
    answer = aws_cloudfront_distribution.this[each.key].domain_name
  }
}

# www CNAME record → CloudFront distribution
resource "ns1_record" "www" {
  for_each = local.configs.sites

  zone   = each.value.domain
  domain = "www.${each.value.domain}"
  type   = "CNAME"
  ttl    = 300

  answers {
    answer = aws_cloudfront_distribution.this[each.key].domain_name
  }
}
