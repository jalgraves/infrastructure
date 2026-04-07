# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# S3 buckets for hosting static site assets behind CloudFront.
# Each site gets its own bucket with restricted access via Origin Access Control.

resource "aws_s3_bucket" "this" {
  for_each = local.configs.sites
  bucket   = each.value.bucket_name

  tags = {
    Name = each.key
    Site = each.value.domain
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = local.configs.sites
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  for_each   = local.configs.sites
  depends_on = [aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.this[each.key].id
  acl        = "private"
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each                = local.configs.sites
  bucket                  = aws_s3_bucket.this[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  for_each = local.configs.sites
  bucket   = aws_s3_bucket.this[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.this[each.key].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this[each.key].arn
          }
        }
      }
    ]
  })
}
