# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_caller_identity" "current" {}

locals {
  contact_form  = local.configs.contact_form
  function_name = "contact-form-${local.configs.region_code}"

  # SES identity ARNs derived from the configured sender domains. Used to
  # scope the send-email IAM policy to only the domains this form uses.
  sender_domains = toset([
    for site in values(local.contact_form.sites) : split("@", site.sender)[1]
  ])
  ses_identity_arns = [
    for domain in local.sender_domains :
    "arn:aws:ses:${local.configs.region}:${data.aws_caller_identity.current.account_id}:identity/${domain}"
  ]
}

# ------------------------------------------------------------------------------
# Package the Lambda source.
# ------------------------------------------------------------------------------
data "archive_file" "contact_form" {
  type        = "zip"
  source_dir  = "${path.module}/src/contact_form"
  output_path = "${path.module}/build/contact_form.zip"
}

# ------------------------------------------------------------------------------
# Execution role.
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "contact_form" {
  name               = local.function_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# CloudWatch Logs (CreateLogGroup/Stream + PutLogEvents).
resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.contact_form.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow sending email only from the configured SES identities.
data "aws_iam_policy_document" "ses_send" {
  statement {
    sid       = "SendContactFormEmail"
    actions   = ["ses:SendEmail"]
    resources = concat(local.ses_identity_arns, ["arn:aws:ses:us-east-1:286957628288:identity/nautoriousyachtcharters@gmail.com"])
  }
}

resource "aws_iam_role_policy" "ses_send" {
  name   = "ses-send-email"
  role   = aws_iam_role.contact_form.id
  policy = data.aws_iam_policy_document.ses_send.json
}

# ------------------------------------------------------------------------------
# Lambda function + log group.
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "contact_form" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = local.contact_form.log_retention_days
}

resource "aws_lambda_function" "contact_form" {
  function_name    = local.function_name
  description      = "Sends contact-form submissions from the CloudFront frontends via SES."
  role             = aws_iam_role.contact_form.arn
  runtime          = local.contact_form.runtime
  handler          = "index.handler"
  filename         = data.archive_file.contact_form.output_path
  source_code_hash = data.archive_file.contact_form.output_base64sha256
  timeout          = local.contact_form.timeout
  memory_size      = local.contact_form.memory_size

  environment {
    variables = {
      # CORS is owned by the Function URL's `cors` block below, not the
      # handler, so `allowed_origins` is not passed to the function.
      SITES = jsonencode(local.contact_form.sites)
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.logs,
    aws_cloudwatch_log_group.contact_form,
  ]
}

# ------------------------------------------------------------------------------
# Public HTTPS endpoint the frontend form POSTs to. CORS is enforced here so
# only the CloudFront frontends can call it from the browser.
# ------------------------------------------------------------------------------
resource "aws_lambda_function_url" "contact_form" {
  function_name      = aws_lambda_function.contact_form.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = local.contact_form.allowed_origins
    allow_methods = ["POST"]
    allow_headers = ["content-type"]
    max_age       = 3600
  }
}
