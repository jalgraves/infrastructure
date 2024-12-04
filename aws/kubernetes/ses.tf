# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_iam_user" "ses_sender" {
  # Automated user for sending SES emails
  name = "${local.configs.cluster_name}-ses-sender"
  path = "/system/"
}

resource "aws_iam_user_policy" "ses_sender" {
  name = "SesSender"
  user = aws_iam_user.ses_sender.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "ses_sender" {
  user   = aws_iam_user.ses_sender.id
  status = "Active"
}
