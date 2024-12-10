# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "roles" {
  value = {
    for role_name, role in local.configs.roles : role_name => aws_iam_role.this[role_name]
  }
}

output "policies" {
  value = {
    for policy_name, policy in local.configs.customer_managed_policies : policy_name => aws_iam_policy.this[policy_name]
  }
}

output "instance_profiles" {
  value = {
    for role_name, role in local.configs.roles : role_name => aws_iam_instance_profile.this[role_name]
    if role.create_instance_profile
  }
}
