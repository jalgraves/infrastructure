# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_iam_role" "k8s_worker" {
  name = "${title(var.env)}${title(var.region_code)}K8sWorker"
  path = "/"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    "Name" = "${title(var.env)}${title(var.region_code)}K8sWorker"
  }
}

resource "aws_iam_instance_profile" "k8s_worker" {
  name = "${title(var.env)}${title(var.region_code)}K8sWorker"
  role = aws_iam_role.k8s_worker.name
}

resource "aws_iam_policy" "k8s_worker" {
  name        = "${title(var.env)}${title(var.region_code)}K8sWorkerPolicy"
  path        = "/"
  description = "Policy for K8s worker nodes. Created Terraform workspace ${terraform.workspace}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:*",
          "elasticloadbalancing:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "sts:AssumeRole",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret",
          "shield:GetSubscriptionState",
          "wafv2:GetWebACLForResource"
        ],
        "Resource" : "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "k8s_worker_route53" {
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "k8s_worker_route53" {
  name        = "${title(var.env)}${title(var.region_code)}K8sWorkerRoute53Policy"
  path        = "/"
  description = "K8s worker node Route53 access used by external-dns. Created via Terraform TFC workspace ${terraform.workspace}"
  policy      = data.aws_iam_policy_document.k8s_worker_route53.json
}

resource "aws_iam_role_policy_attachment" "k8s_worker" {
  role       = aws_iam_role.k8s_worker.name
  policy_arn = aws_iam_policy.k8s_worker.arn
}

resource "aws_iam_role_policy_attachment" "k8s_worker_route53" {
  role       = aws_iam_role.k8s_worker.name
  policy_arn = aws_iam_policy.k8s_worker_route53.arn
}
