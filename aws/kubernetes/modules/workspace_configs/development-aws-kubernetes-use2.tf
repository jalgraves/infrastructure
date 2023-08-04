# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  development-aws-kubernetes-use2 = {
    cilium = {
      version = "1.13.0"
      cidr    = "10.96.0.0/12"
    }
    cluster_name = "development-use2"
    ec2 = {
      instance_type = "t3.medium"
    }
    env = "development"
    k8s = {
      anonymous_auth_enabled        = true
      api_port                      = 6443
      aws_ccm_enabled               = true
      cgroup_driver                 = "systemd"
      cluster_cidr                  = "10.96.0.0/12"
      ebs_csi_driver_enabled        = true
      ha_enabled                    = false
      kubelet_authorization_mode    = "Webhook"
      kubelet_tls_bootstrap_enabled = false
      metrics_server_enabled        = true
      upload_cert_to_aws_enabled    = false
      version                       = "1.27.0"
    }
    org         = "jalgraves"
    region      = "us-east-2"
    region_code = "use2"
  }
}
