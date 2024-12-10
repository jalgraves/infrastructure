# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

data "aws_iam_policy_document" "this" {
  for_each = {
    for policy_name, policy in local.configs.customer_managed_policies : policy_name => policy
  }
  dynamic "statement" {
    for_each = each.value.statements

    content {
      sid     = try(statement.value.sid, null)
      actions = statement.value.actions
      dynamic "condition" {
        for_each = try(statement.value.conditions, [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
      effect    = try(statement.value.effect, "Allow")
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "this" {
  for_each = {
    for policy_name, policy in local.configs.customer_managed_policies : policy_name => policy
  }
  name        = each.key
  path        = each.value.path
  description = each.value.description
  policy      = data.aws_iam_policy_document.this[each.key].json
  tags = {
    Name = each.key
  }
}
