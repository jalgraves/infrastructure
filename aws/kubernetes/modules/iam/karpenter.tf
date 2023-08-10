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
    resources = ["arn:aws:iam::${local.account_id}:role/${title(var.env)}${title(var.region_code)}K8sControlPlane"]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${title(var.env)}${title(var.region_code)}K8sKarpenter"]
  }
}

resource "aws_iam_policy" "karpenter" {
  name        = "${title(var.env)}${title(var.region_code)}K8sKarpenterPolicy"
  path        = "/"
  description = "Karpenter permissions to handle node termination events via the Node Termination Handler. Created via Terraform TFC workspace ${terraform.workspace}"
  policy      = data.aws_iam_policy_document.karpenter.json
  tags = {
    "Name" = "${title(var.env)}${title(var.region_code)}K8sKarpenterPolicy"
  }
}

data "aws_iam_policy_document" "karpenter_assume_role" {
  # Karpenter IRSA
  statement {
    actions = ["sts:AssumeRole", "sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc.provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc.issuer}:sub"

      values = [
        "system:serviceaccount:karpenter:karpenter",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc.issuer}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["spot.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "karpenter" {
  description        = "Role for K8s nodes created by karpenter auto scaling. Created via Terraform TFC workspace ${terraform.workspace}"
  name               = "${title(var.env)}${title(var.region_code)}K8sKarpenter"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
  tags = {
    "Name" = "${title(var.env)}${title(var.region_code)}K8sKarpenter"
  }
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "${title(var.env)}${title(var.region_code)}K8sKarpenter"
  role = aws_iam_role.karpenter.name
  tags = {
    "Name" = "${title(var.env)}${title(var.region_code)}K8sKarpenter"
  }
}


resource "aws_iam_role_policy_attachment" "karpenter" {
  policy_arn = aws_iam_policy.karpenter.arn
  role       = aws_iam_role.karpenter.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter.name
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter.name
}

resource "aws_iam_role_policy_attachment" "amazon_s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.karpenter.name
}
