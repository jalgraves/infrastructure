output "k8s_control_plane" {
  value = {
    private_ip = aws_instance.k8s_control_plane.private_ip
    role = {
      arn = module.iam.k8s_control_plane.role.arn
    }
  }
}

output "karpenter" {
  value = {
    role = {
      arn = module.iam.karpenter.role.arn
    }
  }
}

output "oidc" {
  value = {
    issuer_url   = module.irsa.oidc.issuer
    provider_arn = module.irsa.oidc.provider.arn
  }
}

output "bucket" { value = module.irsa.bucket }

output "oidc2" {
  value = module.irsa.oidc
}
