# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  bucket_name  = "jalgraves-${local.configs.env}-${local.configs.region_code}-static-assets-cdn"
  s3_origin_id = "${title(local.configs.env)}${title(local.configs.region_code)}Jalgraves"
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${local.configs.env}-${local.configs.region_code} static assets CloudFront CDN"
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
  acl    = "private"

  tags = {
    Name = "${local.configs.env}-${local.configs.region_code}"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudfront_distribution" "this" {
  aliases             = local.configs.cdn.aliases
  comment             = "${local.configs.env}-${local.configs.region_code} static assets CloudFront CDN. Created via Terraform workspace ${terraform.workspace}"
  default_root_object = ""
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_200"
  wait_for_deployment = false

  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cdn.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}


resource "aws_route53_record" "a" {
  for_each = {
    for k, v in toset(local.configs.cdn.aliases) : k => v
  }
  name    = "jalgraves"
  type    = "A"
  zone_id = data.aws_route53_zone.cdn[trimprefix(each.value, "jalgraves.")].zone_id

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aaaa" {
  for_each = {
    for k, v in toset(local.configs.cdn.aliases) : k => v
  }
  name    = "jalgraves"
  type    = "AAAA"
  zone_id = data.aws_route53_zone.cdn[trimprefix(each.value, "jalgraves.")].zone_id

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
