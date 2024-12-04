output "k8s_control_plane" {
  value = {
    private_ip = aws_instance.k8s_control_plane.private_ip
    public_ip  = local.configs.k8s.subnet == "public" ? aws_instance.k8s_control_plane.public_ip : null
    role = {
      arn = module.iam.k8s_control_plane.role.arn
    }
  }
}

output "oidc" {
  value = {
    issuer_url   = module.irsa.oidc.issuer
    provider_arn = module.irsa.oidc.provider.arn
  }
}

output "bucket" {
  value = {
    arn = module.irsa.bucket.arn
  }
}

output "oidc2" {
  value = module.irsa.oidc
}

output "automated_users" {
  value = {
    kubernetes_cluster_autoscaler = {
      access_key_id     = aws_iam_access_key.kubernetes_cluster_autoscaler.id,
      secret_access_key = aws_iam_access_key.kubernetes_cluster_autoscaler.secret
    }
  }
  sensitive = true
}

output "app_roles" {
  value = module.iam.app_role_arns
}
