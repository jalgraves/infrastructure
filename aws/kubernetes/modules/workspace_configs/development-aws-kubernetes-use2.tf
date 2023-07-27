# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  development-aws-kubernetes-use2 = {
    cilium = {
      version = "1.9.5"
      cidr    = "10.96.0.0/12"
    }
    cluster_name = "development-use2"
    ec2          = {}
    k8s = {
      anonymous_auth_enabled        = false
      cluster_cidr                  = "10.96.0.0/12"
      version                       = "1.27"
      cgroup_driver                 = "systemd"
      metrics_server_enabled        = true
      kubelet_authorization_mode    = ""
      kubelet_tls_bootstrap_enabled = false
      upload_cert_to_aws_enabled    = true
    }
  }
}
