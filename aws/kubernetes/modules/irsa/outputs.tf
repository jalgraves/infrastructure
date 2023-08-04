# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "bucket" {
  value = aws_s3_bucket.oidc
}

output "cert" {
  value = local.cert.sha1_fingerprint
}

output "oidc" {
  description = "OIDC provider"
  value = {
    provider = aws_iam_openid_connect_provider.irsa
    issuer   = aws_s3_bucket.oidc.bucket_domain_name
  }
}
