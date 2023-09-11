# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_iam_policy_document" "irsa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc.provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc.issuer}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

locals {
  apps = [
    {
      name = "contact-api"
      role = "${title(var.env)}${title(var.region_code)}ContactAPI"
    },
    {
      name = "menu-api"
      role = "${title(var.env)}${title(var.region_code)}MenuAPI"
    },
    {
      name = "merch-api"
      role = "${title(var.env)}${title(var.region_code)}MerchAPI"
    },
    {
      name = "users-api"
      role = "${title(var.env)}${title(var.region_code)}UsersAPI"
    },
    {
      name = "beantown"
      role = "${title(var.env)}${title(var.region_code)}Beantown"
    },
    {
      name = "thehubpub"
      role = "${title(var.env)}${title(var.region_code)}TheHubPub"
    },
    {
      name = "external-secrets"
      role = "${title(var.env)}${title(var.region_code)}ExternalSecrets"
    }
  ]
}

resource "aws_iam_role" "app_roles" {
  for_each = {
    for app in local.apps : app.name => app
  }
  description        = "Role for ${each.value.name}. Created via Terraform TFC workspace ${terraform.workspace}"
  name               = each.value.role
  assume_role_policy = data.aws_iam_policy_document.irsa.json
  tags = {
    "Name" = each.value.role
  }
}


resource "aws_iam_policy" "secretsmanager_read" {
  name        = "${title(var.env)}${title(var.region_code)}SecretsManagerRead"
  path        = "/"
  description = "Policy for reading secrets from secretsmanager. Created Terraform workspace ${terraform.workspace}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ses_send" {
  name        = "${title(var.env)}${title(var.region_code)}SesSend"
  path        = "/"
  description = "Policy for sending email from ses. Created Terraform workspace ${terraform.workspace}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_roles_secretsmanager_read" {
  for_each = {
    for app in local.apps : app.name => app
  }
  policy_arn = aws_iam_policy.secretsmanager_read.arn
  role       = aws_iam_role.app_roles[each.value.name].name
}

resource "aws_iam_role_policy_attachment" "contact_api_ses_send" {
  policy_arn = aws_iam_policy.ses_send.arn
  role       = aws_iam_role.app_roles["contact-api"].name
}
