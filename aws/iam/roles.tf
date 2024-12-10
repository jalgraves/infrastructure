# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

data "aws_iam_policy_document" "assume_role" {
  for_each = {
    for role_name, role in local.configs.roles : role_name => role
  }
  dynamic "statement" {
    for_each = each.value.assume_role.statements

    content {
      actions = statement.value.actions
      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
      principals {
        type        = statement.value.principals.type
        identifiers = statement.value.principals.identifiers
      }
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = {
    for role_name, role in local.configs.roles : role_name => role
  }
  description        = each.value.description
  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
  tags = {
    Name = each.key
  }
}

resource "aws_iam_role_policy_attachment" "managed" {
  # Attach AWS managed policies to a role
  for_each = {
    for item in flatten([
      for role_name, role in local.configs.roles : [
        for policy_arn in role.managed_policy_attachments : {
          role_name  = role_name
          policy_arn = policy_arn
        }
      ]
    ])
    : "${item.role_name}:${item.policy_arn}" => item
  }
  policy_arn = each.value.policy_arn
  role       = aws_iam_role.this[each.value.role_name].name
}


resource "aws_iam_role_policy_attachment" "this" {
  for_each = {
    for item in flatten([
      for role_name, role in local.configs.roles : [
        for policy_name in role.customer_managed_policy_attachments : {
          role_name   = role_name
          policy_name = policy_name
        }
      ]
    ])
    : "${item.role_name}:${item.policy_name}" => item
  }
  policy_arn = aws_iam_policy.this[each.value.policy_name].arn
  role       = aws_iam_role.this[each.value.role_name].name
}

resource "aws_iam_instance_profile" "this" {
  for_each = {
    for role_name, role in local.configs.roles : role_name => role
    if role.create_instance_profile
  }
  name = each.key
  role = aws_iam_role.this[each.key].name
}
