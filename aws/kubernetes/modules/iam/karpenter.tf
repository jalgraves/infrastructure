# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "karpenter" {
  statement {
    actions = [
      "pricing:GetProducts",
      "ec2:DescribeSubnets",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeImages",
      "ec2:DescribeAvailabilityZones",
      "ec2:CreateTags",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["ec2:TerminateInstances", "ec2:DeleteLaunchTemplate"]
    resources = ["*"]
  }
  statement {
    actions = ["ec2:RunInstances"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/karpenter.sh/discovery/${var.cluster_name}"
      values   = [var.cluster_name]
    }
    resources = [
      "arn:aws:ec2:*:${local.account_id}:security-group/*",
      "arn:aws:ec2:*:${local.account_id}:launch-template/*"
    ]
  }
  statement {
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:aws:ec2:*::image/*",
      "arn:aws:ec2:*:${local.account_id}:volume/*",
      "arn:aws:ec2:*:${local.account_id}:subnet/*",
      "arn:aws:ec2:*:${local.account_id}:spot-instances-request/*",
      "arn:aws:ec2:*:${local.account_id}:network-interface/*",
      "arn:aws:ec2:*:${local.account_id}:instance/*",
      "arn:aws:ec2:*:${local.account_id}:security-group/*"
    ]
  }
  statement {
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/aws/service/*"]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${title(var.env)}${title(var.region_code)}EKSCluster"]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${title(var.env)}${title(var.region_code)}EKSKarpenter"]
  }
}

resource "aws_iam_policy" "karpenter" {
  name        = "${title(var.env)}${title(var.region_code)}EKSKarpenterPolicy"
  path        = "/"
  description = "Karpenter permissions to handle node termination events via the Node Termination Handler. Created via Terraform TFC workspace ${terraform.workspace}"
  policy      = data.aws_iam_policy_document.karpenter.json
}


data "aws_iam_policy_document" "karpenter_assume_role" {
  # Karpenter IRSA
  statement {
    actions = ["sts:AssumeRole", "sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Service"
      identifiers = ["sts.amazonaws.com", "spot.amazonaws.com"]
    }
  }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "karpenter" {
  description        = "Role for EKS nodes created by karpenter auto scaling. Created via Terraform TFC workspace ${terraform.workspace}"
  name               = "${title(var.env)}${title(var.region_code)}EKSKarpenter"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "${title(var.env)}${title(var.region_code)}Karpenter"
  role = aws_iam_role.karpenter.name
}


resource "aws_iam_role_policy_attachment" "karpenter" {
  policy_arn = aws_iam_policy.karpenter.arn
  role       = aws_iam_role.karpenter.name
}
