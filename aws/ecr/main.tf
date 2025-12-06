# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

# Private image replication
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/replication.html

# Pull through cache
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  repository_policies = {
    default = <<EOF
      {
        "Version": "2008-10-17",
        "Statement": [
          {
            "Sid": "PrivateRepositoryPolicy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "ecr:BatchCheckLayerAvailability",
              "ecr:BatchDeleteImage",
              "ecr:BatchGetImage",
              "ecr:CompleteLayerUpload",
              "ecr:DeleteRepository",
              "ecr:DeleteRepositoryPolicy",
              "ecr:DescribeRepositories",
              "ecr:GetDownloadUrlForLayer",
              "ecr:GetRepositoryPolicy",
              "ecr:InitiateLayerUpload",
              "ecr:ListImages",
              "ecr:PutImage",
              "ecr:SetRepositoryPolicy",
              "ecr:UploadLayerPart"
            ]
          }
        ]
      }
      EOF
  }
}

resource "aws_ecr_repository" "this" {
  for_each             = toset(local.configs.repositories)
  name                 = each.value
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository_policy" "this" {
  for_each   = toset(local.configs.repositories)
  repository = each.value

  policy     = local.repository_policies.default
  depends_on = [aws_ecr_repository.this]
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = {
    for k, v in toset(local.configs.repositories) : k => v
  }
  repository = each.value
  policy     = local.lifecycle_policies["keep-last-5"]
  depends_on = [aws_ecr_repository.this]
}
