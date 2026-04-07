# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# CloudFront distributions for serving static sites from S3.
# Uses Origin Access Control (OAC) instead of the legacy Origin Access Identity (OAI).

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = local.configs.sites

  name                              = each.key
  description                       = "OAC for ${each.value.domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  for_each = local.configs.sites

  aliases             = [each.value.domain, "www.${each.value.domain}"]
  comment             = "${each.value.domain} - managed by Terraform workspace ${terraform.workspace}"
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  wait_for_deployment = true
  http_version        = "http2and3"

  origin {
    domain_name              = aws_s3_bucket.this[each.key].bucket_regional_domain_name
    origin_id                = "S3-${each.key}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this[each.key].id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = "S3-${each.key}"
    viewer_protocol_policy = "redirect-to-https"

    # Cache policy: CachingOptimized (managed by AWS)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # Cache static assets with long TTL
  ordered_cache_behavior {
    path_pattern           = "/assets/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = "S3-${each.key}"
    viewer_protocol_policy = "redirect-to-https"

    # Cache policy: CachingOptimized (managed by AWS)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # SPA routing: return index.html for 403/404 so React Router handles all paths
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.this[each.key].arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    Name = each.key
    Site = each.value.domain
  }
}
