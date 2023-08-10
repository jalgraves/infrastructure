# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  bucket_name  = "${var.org}-${local.configs.env}-${local.configs.region_code}-static-assets-cdn"
  s3_origin_id = "${title(local.configs.env)}${title(local.configs.region_code)}${title(var.org)}"
}

resource "aws_cloudfront_origin_access_identity" "this" {
  count   = local.configs.cdn.enabled ? 1 : 0
  comment = "${var.org} ${local.configs.env}-${local.configs.region_code} static assets CloudFront CDN"
}

resource "aws_s3_bucket" "this" {
  count  = local.configs.cdn.enabled ? 1 : 0
  bucket = local.bucket_name

  tags = {
    Name = "${local.configs.env}-${local.configs.region_code}"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = local.configs.cdn.enabled ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  count      = local.configs.cdn.enabled ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.this[0]]

  bucket = aws_s3_bucket.this[0].id
  acl    = "private"
}

resource "aws_cloudfront_distribution" "this" {
  count               = local.configs.cdn.enabled ? 1 : 0
  aliases             = local.configs.cdn.aliases
  comment             = "${local.configs.env}-${local.configs.region_code} static assets CloudFront CDN. Created via Terraform workspace ${terraform.workspace}"
  default_root_object = ""
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_200"
  wait_for_deployment = false

  origin {
    domain_name = aws_s3_bucket.this[0].bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path
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
    #acm_certificate_arn      = aws_acm_certificate.cdn.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

data "aws_route53_zone" "cdn" {
  count = local.configs.cdn.enabled ? 1 : 0
  name  = "${local.configs.env}.${local.configs.region_code}.aws.${var.org}.com"
}


resource "aws_route53_record" "a" {
  for_each = {
    for k, v in toset(local.configs.cdn.aliases) : k => v
    if local.configs.cdn.enabled
  }
  name    = "cdn"
  type    = "A"
  zone_id = data.aws_route53_zone.cdn[0].zone_id

  alias {
    name                   = aws_cloudfront_distribution.this[0].domain_name
    zone_id                = aws_cloudfront_distribution.this[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aaaa" {
  for_each = {
    for k, v in toset(local.configs.cdn.aliases) : k => v
    if local.configs.cdn.enabled
  }
  name    = "cdn"
  type    = "AAAA"
  zone_id = data.aws_route53_zone.cdn[0].zone_id

  alias {
    name                   = aws_cloudfront_distribution.this[0].domain_name
    zone_id                = aws_cloudfront_distribution.this[0].hosted_zone_id
    evaluate_target_health = false
  }
}
