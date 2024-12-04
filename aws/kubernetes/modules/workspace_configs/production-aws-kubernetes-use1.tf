# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-aws-kubernetes-use1 = {
    aws_external_dns = {
      enabled  = true
      replicas = 1
    }
    aws_load_balancer_controller = {
      enabled  = true
      replicas = 1
    }
    argocd = {
      enabled = true
    }
    cilium = {
      version = "1.13.0"
      cidr    = "10.96.0.0/12"
    }
    cluster_name = "production-use1"
    ec2 = {
      instance_type = "t3.medium"
    }
    env = "production"
    k8s = {
      anonymous_auth_enabled        = true
      cert_manager_enabled          = true
      cgroup_driver                 = "systemd"
      cloud_provider                = "external"
      cluster_cidr                  = "10.96.0.0/12"
      cluster_autoscaler_enabled    = true
      ebs_csi_driver_enabled        = true
      external_dns_enabled          = false
      kubelet_authorization_mode    = "Webhook"
      kubelet_tls_bootstrap_enabled = true
      metrics_server_enabled        = true
      pod_identity_webhook_enabled  = true
      version                       = "1.31.0"
      subnet                        = "public"
    }
    region      = "us-east-1"
    region_code = "use1"
    tailscale = {
      enabled = false
    }
  }
}
