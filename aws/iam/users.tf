# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

resource "aws_iam_user" "automated_users" {
  for_each = {
    for username, user in local.configs.automated_users : username => user
  }
  name = each.key
}

resource "aws_iam_access_key" "automated_users" {
  for_each = {
    for username, user in local.configs.automated_users : username => user
    if user.create_keys
  }
  user   = aws_iam_user.automated_users[each.key].id
  status = "Active"
}

resource "aws_secretsmanager_secret" "automated_users" {
  for_each = {
    for username, user in local.configs.automated_users : username => user
  }
  description             = each.value.secret.description
  name                    = each.value.secret.name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "automated_users_keys" {
  for_each = {
    for username, user in local.configs.automated_users : username => user
  }
  secret_id = aws_secretsmanager_secret.automated_users[each.key].id
  secret_string = jsonencode(
    {
      AWS_ACCESS_KEY_ID     = aws_iam_access_key.automated_users[each.key].id,
      AWS_SECRET_ACCESS_KEY = aws_iam_access_key.automated_users[each.key].secret
    }
  )
}

resource "aws_iam_user_policy_attachment" "automated_users_managed" {
  # Attach AWS managed policies to a user
  for_each = {
    for item in flatten([
      for username, user in local.configs.automated_users : [
        for policy_arn in user.managed_policy_attachments : {
          username   = username
          policy_arn = policy_arn
        }
      ]
    ])
    : "${item.username}:${item.policy_arn}" => item
  }
  policy_arn = each.value.policy_arn
  user       = aws_iam_user.automated_users[each.value.username].name
}

resource "aws_iam_user_policy_attachment" "automated_users_customer_managed" {
  for_each = {
    for item in flatten([
      for username, user in local.configs.automated_users : [
        for policy_name in user.customer_managed_policy_attachments : {
          username    = username
          policy_name = policy_name
        }
      ]
    ])
    : "${item.username}:${item.policy_name}" => item
  }
  policy_arn = aws_iam_policy.this[each.value.policy_name].arn
  user       = aws_iam_user.automated_users[each.value.username].name
}
