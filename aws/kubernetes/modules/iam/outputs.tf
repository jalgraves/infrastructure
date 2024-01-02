# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "k8s_control_plane" {
  description = "The instance profile, role, and policy used by Kubernetes control plane."
  value = {
    instance_profile = aws_iam_instance_profile.k8s_control_plane
    role             = aws_iam_role.k8s_control_plane
    policy           = aws_iam_policy.k8s_control_plane
  }
}

output "k8s_worker" {
  description = "The instance profile, role, and policy used by Kubernetes worker nodes."
  value = {
    instance_profile = aws_iam_instance_profile.k8s_worker
    role             = aws_iam_role.k8s_worker
    policy           = aws_iam_policy.k8s_worker
  }
}

output "app_role_arns" {
  description = "ARNs for IRSA roles used by running applications in Kubernetes cluster."
  value       = { for app in local.apps : app.name => aws_iam_role.app_roles[app.name].arn }
}
