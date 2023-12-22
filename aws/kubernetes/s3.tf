# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_region" "current" {}

resource "aws_s3_bucket" "cluster_scripts" {
  bucket = "${var.org}-${local.configs.cluster_name}-cluster-scripts"
}

resource "aws_s3_bucket_ownership_controls" "cluster_scripts" {
  bucket = aws_s3_bucket.cluster_scripts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cluster_scripts" {
  bucket     = aws_s3_bucket.cluster_scripts.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.cluster_scripts]
}

resource "aws_s3_bucket_public_access_block" "cluster_scripts" {
  bucket                  = aws_s3_bucket.cluster_scripts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cluster_scripts" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.cluster_scripts.id}/*"]

    principals {
      type        = "AWS"
      identifiers = [module.iam.k8s_control_plane.role.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cluster_scripts" {
  bucket = aws_s3_bucket.cluster_scripts.id
  policy = data.aws_iam_policy_document.cluster_scripts.json
}

resource "aws_s3_object" "kubeadm_init" {
  bucket = aws_s3_bucket.cluster_scripts.id
  key    = "kubeadm_init.sh"
  source = "${path.module}/cluster_scripts/kubeadm_init.sh"
  etag   = filemd5("${path.module}/cluster_scripts/kubeadm_init.sh")
  depends_on = [
    aws_s3_bucket_acl.cluster_scripts,
    aws_s3_bucket_public_access_block.cluster_scripts,
    aws_s3_bucket_policy.cluster_scripts
  ]
}

resource "aws_s3_object" "helm_install" {
  bucket = aws_s3_bucket.cluster_scripts.id
  key    = "helm_install.sh"
  source = "${path.module}/cluster_scripts/helm_install.sh"
  etag   = filemd5("${path.module}/cluster_scripts/helm_install.sh")
  depends_on = [
    aws_s3_bucket_acl.cluster_scripts,
    aws_s3_bucket_public_access_block.cluster_scripts,
    aws_s3_bucket_policy.cluster_scripts
  ]
}

# resource "aws_s3_object" "create_secrets" {
#   bucket = aws_s3_bucket.cluster_scripts.id
#   key    = "create_secrets.sh"
#   source = "${path.module}/cluster_scripts/create_secrets.sh"
#   etag   = filemd5("${path.module}/cluster_scripts/create_secrets.sh")
#   depends_on = [
#     aws_s3_bucket_acl.cluster_scripts,
#     aws_s3_bucket_public_access_block.cluster_scripts,
#     aws_s3_bucket_policy.cluster_scripts
#   ]
# }
