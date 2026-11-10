# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
  aws_service_access_principals = [
    "account-access.amazonaws.com",
    "account.amazonaws.com",
    "compute-optimizer.amazonaws.com",
    "cost-optimization-hub.bcm.amazonaws.com",
    "iam.amazonaws.com",
    "notifications.amazonaws.com",
    "sso.amazonaws.com",
    "guardduty.amazonaws.com",
    "servicecatalog.amazonaws.com",
  ]

  enabled_policy_types = [
    "RESOURCE_CONTROL_POLICY",
    "SERVICE_CONTROL_POLICY",
    "GUARDDUTY_POLICY",
  ]

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_organizational_unit" "parent" {
  for_each = {
    for ou_name, ou in local.organizational_units : ou_name => ou
  }
  name      = each.key
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_account" "this" {
  for_each = {
    for account_name, account in local.accounts : account_name => account
  }
  name      = each.key
  email     = each.value.email
  parent_id = aws_organizations_organizational_unit.parent[each.value.organizational_unit].id
}
