# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  production-aws-kubernetes-use2 = {
    cilium = {
      version = "1.13.0"
      cidr    = "10.96.0.0/12"
    }
    cluster_name = "production-use2"
    ec2 = {
      instance_type = "t3.medium"
    }
    env = "production"
    k8s = {
      anonymous_auth_enabled               = false
      aws_ccm_enabled                      = true
      aws_load_balancer_controller_enabled = true
      cert_manager_enabled                 = true
      cgroup_driver                        = "systemd"
      cluster_cidr                         = "10.96.0.0/12"
      ebs_csi_driver_enabled               = true
      external_dns_enabled                 = true
      istio_enabled                        = true
      kubelet_authorization_mode           = "Webhook"
      kubelet_tls_bootstrap_enabled        = true
      metrics_server_enabled               = true
      pod_identity_webhook_enabled         = true
      version                              = "1.27.0"
    }
    karpenter = {
      enabled  = true
      replicas = 1
      version  = "v0.27.5"
    }
    region      = "us-east-2"
    region_code = "use2"
  }
}
