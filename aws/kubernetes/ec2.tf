# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_caller_identity" "current" {}

locals {

  template_vars = {
    # ha_enabled                    = local.configs.k8s.ha_enabled,
    anonymous_auth_enabled        = local.configs.k8s.anonymous_auth_enabled
    api_port                      = local.configs.k8s.api_port
    automated_user                = var.automated_user
    aws_account_id                = data.aws_caller_identity.current.account_id
    aws_ccm_enabled               = local.configs.k8s.aws_ccm_enabled
    aws_region                    = local.configs.region
    cgroup_driver                 = local.configs.k8s.cgroup_driver
    cilium_cidr                   = local.configs.cilium.cidr
    cilium_version                = local.configs.cilium.version
    cluster_cidr                  = local.configs.k8s.cluster_cidr
    cluster_name                  = local.configs.cluster_name
    control_plane_endpoint        = local.configs.k8s.control_plane_endpoint
    domain_name                   = var.domain_name
    ebs_csi_driver_enabled        = local.configs.k8s.ebs_csi_driver_enabled
    env                           = local.configs.env
    karpenter_instance_profile    = module.iam.karpenter.instance_profile.name
    karpenter_version             = "v0.27.5"
    kubelet_authorization_mode    = local.configs.k8s.kubelet_authorization_mode
    kubelet_tls_bootstrap_enabled = local.configs.k8s.kubelet_tls_bootstrap_enabled
    kubernetes_version            = local.configs.k8s.version
    listener_arn                  = "foo"
    metrics_server_enabled        = local.configs.k8s.metrics_server_enabled
    nlb_hostname                  = var.nlb_hostname
    region_code                   = local.configs.region_code
    upload_cert_to_aws_enabled    = local.configs.k8s.upload_cert_to_aws_enabled
  }
  k8s_control_plane_user_data = templatefile("${path.module}/templates/control_plane_user_data.sh", local.template_vars)
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "k8s_control_plane" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = local.configs.ec2.instance_type
  user_data                   = local.k8s_control_plane_user_data
  security_groups             = [aws_security_group.internal_traffic.id]
  iam_instance_profile        = module.iam.k8s_control_plane.instance_profile.name
  associate_public_ip_address = false
  key_name                    = data.tfe_outputs.vpc.values.tailscale.key_pair.name
  subnet_id                   = data.tfe_outputs.vpc.values.subnets.private.ids[0]
  tags = {
    "Name" = "${local.configs.cluster_name}-k8s-control-plane"
    "Role" = "control-plane"
    #"kubernetes.io/cluster/${local.configs.cluster_name}" = "owned"
  }
  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
  root_block_device {
    encrypted   = false
    volume_size = 25
    volume_type = "gp3"
  }
}
