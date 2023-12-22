# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_ssoadmin_permission_set" "this" {
  instance_arn = "arn:aws:sso:::instance/ssoins-7223daaadf63eeb8"
  name         = "SecurityAudit"
}

output "ssoadmin_instances" {
  value = data.aws_ssoadmin_instances.this
}

output "permission_sets" {
  value = data.aws_ssoadmin_permission_set.this
}

output "groups" {
  value = data.aws_identitystore_group.this
}

# data "aws_identitystore_user" "example" {
#   identity_store_id = "d-906788296c"
#   user_id = "e45834f8-90a1-700b-d0c0-990ca0027647"

# }

# output "users" {
#   value = data.aws_identitystore_user.example
# }
