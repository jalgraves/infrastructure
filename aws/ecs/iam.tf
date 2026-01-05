data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "secrets_read_only" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:GetResourcePolicy"
    ]

    resources = [
      data.aws_secretsmanager_secret_version.psql.arn,
      data.aws_secretsmanager_secret_version.menu-api.arn,
      data.aws_secretsmanager_secret_version.contact-api.arn,
      data.aws_secretsmanager_secret_version.beantownpub.arn
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = [
      "arn:aws:kms:${local.configs.region}:${local.account_id}:key/aws/secretsmanager"
    ]
  }
}

resource "aws_iam_policy" "secrets_policy" {
  name   = "secrets-manager-read-only"
  policy = data.aws_iam_policy_document.secrets_read_only.json
}
