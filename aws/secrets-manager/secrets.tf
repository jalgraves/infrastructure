# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

resource "aws_secretsmanager_secret" "this" {
  for_each = {
    for secret_name, secret in local.configs.secrets : secret_name => secret
  }
  description             = each.value.description
  name                    = each.key
  recovery_window_in_days = 0
  tags = {
    # This tag is used in IAM policy conditions to allow access to secrets
    SecretType = each.value.secret_type
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = {
    for secret_name, secret in local.configs.secrets : secret_name => secret
  }
  secret_id = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.key != "contact-api" ? jsonencode(
    { for secret_name, secret in each.value.secrets : secret_name => secret }
    ) : jsonencode(merge(
      { for secret_name, secret in each.value.secrets : secret_name => secret },
      {
        AWS_ACCESS_KEY_ID     = aws_iam_access_key.contact-api.id,
        AWS_SECRET_ACCESS_KEY = aws_iam_access_key.contact-api.secret
      }
  ))
  depends_on = [aws_secretsmanager_secret.this]
}
