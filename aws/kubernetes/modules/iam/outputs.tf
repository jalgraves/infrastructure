# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "k8s_control_plane" {
  value = {
    instance_profile = aws_iam_instance_profile.k8s_control_plane
    role             = aws_iam_role.k8s_control_plane
    policy           = aws_iam_policy.k8s_control_plane
  }
}

output "k8s_worker" {
  value = {
    instance_profile = aws_iam_instance_profile.k8s_worker
    role             = aws_iam_role.k8s_worker
    policy           = aws_iam_policy.k8s_worker
  }
}

output "app_role_arns" {
  value = { for app in local.apps : app.name => aws_iam_role.app_roles[app.name].arn }

  #  value = aws_iam_role.app_roles
}
