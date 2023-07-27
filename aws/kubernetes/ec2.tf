# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_key_pair" "cluster_nodes" {
  key_name   = "${local.configs.cluster_name}-k8s-control-plane"
  public_key = local.configs.ec2.public_key
}

data "template_file" "init" {
  template = file("${path.module}/templates/user_data.sh")
  vars = {
    automated_user                = local.configs.k8s.automated_user
    cilium_version                = local.configs.cilium.version
    cilium_cidr                   = local.configs.cilium.cidr
    cluster_name                  = local.configs.cluster_name
    cluster_cidr                  = local.configs.k8s.cluster_cidr
    domain_name                   = local.configs.k8s.domain_name
    env                           = local.configs.env
    istio_version                 = local.configs.istio.version
    kubernetes_api_hostname       = local.configs.k8s.api_hostname
    kubernetes_join_token         = local.configs.k8s.join_token
    kubernetes_version            = local.configs.k8s.version
    anonymous_auth_enabled        = local.configs.k8s.anonymous_auth_enabled,
    api_port                      = local.configs.k8sapi_port,
    argocd_enabled                = local.configs.argocd_enabled,
    aws_account_id                = var.aws_account_id,
    aws_ccm_enabled               = local.configs.k8s.aws_ccm_enabled,
    aws_region                    = local.configs.aws_region
    control_plane_endpoint        = local.configs.k8s.control_plane_endpoint,
    cgroup_driver                 = local.configs.k8s.cgroup_driver,
    cluster_cidr                  = local.configs.k8s.cluster_cidr,
    ebs_csi_driver_enabled        = local.configs.k8s.ebs_csi_driver_enabled,
    ha_enabled                    = local.configs.k8s.ha_enabled,
    kubelet_authorization_mode    = local.configs.k8s.kubelet_authorization_mode,
    kubelet_tls_bootstrap_enabled = local.configs.k8s.kubelet_tls_bootstrap_enabled,
    listener_arn                  = local.listener,
    metrics_server_enabled        = local.configs.k8s.metrics_server_enabled,
    nlb_hostname                  = local.configs.nlb_hostname,
    stage                         = local.configs.stage,
    upload_cert_to_aws_enabled    = local.configs.k8s.upload_cert_to_aws_enabled
  }
}

resource "aws_instance" "control_plane" {
  ami                         = local.configs.ec2.ami
  instance_type               = local.configs.ec2.instance_type
  user_data                   = data.template_file.init.rendered
  security_groups             = local.configs.ec2.security_groups
  iam_instance_profile        = local.configs.ec2.iam_instance_profile
  associate_public_ip_address = local.configs.ec2.associate_public_ip_address
  key_name                    = aws_key_pair.cluster_nodes.key_name
  subnet_id                   = data.tfe_outputs.vpc.values.subnets.private.ids[0]
  tags = {
    "Name"                                                = "${local.configs.cluster_name}-k8s-control-plane"
    "Role"                                                = "control-plane"
    "kubernetes.io/cluster/${local.configs.cluster_name}" = "owned"
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
