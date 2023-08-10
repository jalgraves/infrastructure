# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "oidc" {
  bucket = "${var.org}-${var.cluster_name}-oidc"
}

resource "aws_s3_bucket_ownership_controls" "oidc" {
  bucket = aws_s3_bucket.oidc.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "oidc" {
  bucket     = aws_s3_bucket.oidc.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.oidc]
}

resource "aws_s3_bucket_public_access_block" "oidc" {
  bucket                  = aws_s3_bucket.oidc.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.oidc.id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "oidc" {
  bucket = aws_s3_bucket.oidc.id
  policy = data.aws_iam_policy_document.oidc.json
}

resource "aws_s3_object" "oidc_discovery" {
  bucket  = aws_s3_bucket.oidc.id
  key     = "/.well-known/openid-configuration"
  acl     = "public-read"
  content = <<EOF
{
  "issuer": "https://${aws_s3_bucket.oidc.bucket_domain_name}/",
  "jwks_uri": "https://${aws_s3_bucket.oidc.bucket_domain_name}/jwks.json",
  "authorization_endpoint": "urn:kubernetes:programmatic_authorization",
  "response_types_supported": [
    "id_token"
  ],
  "subject_types_supported": [
    "public"
  ],
  "id_token_signing_alg_values_supported": [
    "RS256"
  ],
  "claims_supported": [
    "sub",
    "iss"
  ]
}
EOF
  depends_on = [
    aws_s3_bucket_acl.oidc,
    aws_s3_bucket_public_access_block.oidc,
    aws_s3_bucket_policy.oidc
  ]
}

resource "aws_s3_object" "oidc_jwks" {
  bucket  = aws_s3_bucket.oidc.id
  key     = "/jwks.json"
  acl     = "public-read"
  content = base64decode(var.oidc_jwks)
  depends_on = [
    aws_s3_bucket_acl.oidc,
    aws_s3_bucket_public_access_block.oidc,
    aws_s3_bucket_policy.oidc
  ]
}

data "tls_certificate" "this" {
  url = "https://${aws_s3_bucket.oidc.bucket_regional_domain_name}"
}

locals {
  cert = data.tls_certificate.this.certificates[index(data.tls_certificate.this.certificates[*].subject, "CN=*.s3.${data.aws_region.current.id}.amazonaws.com")]
}

resource "aws_iam_openid_connect_provider" "irsa" {
  url             = "https://${aws_s3_bucket.oidc.bucket_domain_name}"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.cert.sha1_fingerprint]
  depends_on      = [data.tls_certificate.this]
}
