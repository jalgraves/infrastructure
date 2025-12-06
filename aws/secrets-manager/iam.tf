resource "aws_iam_user" "contact-api" {
  name = "contact-api"
  path = "/system/"
}

resource "aws_iam_access_key" "contact-api" {
  user   = aws_iam_user.contact-api.id
  status = "Active"
}

data "aws_iam_policy_document" "contact-api" {
  statement {
    effect = "Allow"

    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "contact-api" {
  name   = "contact-api"
  policy = data.aws_iam_policy_document.contact-api.json
}

resource "aws_iam_user_policy_attachment" "contact-api" {
  user       = aws_iam_user.contact-api.name
  policy_arn = aws_iam_policy.contact-api.arn
}

