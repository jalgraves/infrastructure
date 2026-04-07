# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "distributions" {
  description = "CloudFront distribution details for each site."
  value = {
    for site_name, site in local.configs.sites : site_name => {
      domain_name     = aws_cloudfront_distribution.this[site_name].domain_name
      distribution_id = aws_cloudfront_distribution.this[site_name].id
      arn             = aws_cloudfront_distribution.this[site_name].arn
    }
  }
}

output "buckets" {
  description = "S3 bucket details for each site."
  value = {
    for site_name, site in local.configs.sites : site_name => {
      bucket = aws_s3_bucket.this[site_name].bucket
      arn    = aws_s3_bucket.this[site_name].arn
    }
  }
}
