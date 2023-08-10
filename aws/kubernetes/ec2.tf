# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_caller_identity" "current" {}

locals {
  cert_arns = concat([data.tfe_outputs.route53.values.acm.certificates.env.arn], data.tfe_outputs.certs[0].values.acm.certificates.client_domain_arns)

  template_vars = {
    anonymous_auth_enabled               = local.configs.k8s.anonymous_auth_enabled
    api_port                             = var.api_port
    automated_user                       = var.automated_user
    availability_zones                   = join(",", data.tfe_outputs.vpc.values.subnets.availability_zones)
    aws_account_id                       = data.aws_caller_identity.current.account_id
    aws_load_balancer_controller_enabled = local.configs.k8s.aws_load_balancer_controller_enabled
    aws_region                           = local.configs.region
    cert_arns                            = join(",", local.cert_arns)
    cert_manager_enabled                 = local.configs.k8s.cert_manager_enabled
    cgroup_driver                        = local.configs.k8s.cgroup_driver
    cilium_cidr                          = local.configs.cilium.cidr
    cilium_version                       = local.configs.cilium.version
    cluster_cidr                         = local.configs.k8s.cluster_cidr
    cluster_domain                       = var.cluster_domain
    cluster_name                         = local.configs.cluster_name
    control_plane_endpoint               = var.control_plane_endpoint
    ebs_csi_driver_enabled               = local.configs.k8s.ebs_csi_driver_enabled
    env                                  = local.configs.env
    external_dns_enabled                 = local.configs.k8s.external_dns_enabled
    gateway_domains                      = join(",", var.gateway_domains)
    karpenter_enabled                    = local.configs.karpenter.enabled
    istio_enabled                        = local.configs.k8s.istio_enabled
    karpenter_instance_profile           = module.iam.karpenter.instance_profile.name
    karpenter_replicas                   = local.configs.karpenter.replicas
    karpenter_service_account_role_arn   = module.iam.karpenter.role.arn
    karpenter_version                    = local.configs.karpenter.version
    kubelet_authorization_mode           = local.configs.k8s.kubelet_authorization_mode
    kubelet_tls_bootstrap_enabled        = local.configs.k8s.kubelet_tls_bootstrap_enabled
    kubernetes_version                   = local.configs.k8s.version
    metrics_server_enabled               = local.configs.k8s.metrics_server_enabled
    org                                  = var.org
    pod_identity_webhook_enabled         = local.configs.k8s.pod_identity_webhook_enabled
    region_code                          = local.configs.region_code
    sa_signer_key                        = var.sa_signer_key
    sa_signer_pkcs8_pub                  = var.sa_signer_pkcs8_pub
    service_account_issuer_url           = "https://${module.irsa.oidc.issuer}"
    ssh_public_key                       = data.tfe_outputs.vpc.values.tailscale.public_ssh_key
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
  iam_instance_profile        = module.iam.k8s_control_plane.instance_profile.name
  associate_public_ip_address = false
  key_name                    = data.tfe_outputs.vpc.values.tailscale.key_pair.name
  subnet_id                   = data.tfe_outputs.vpc.values.subnets.private.ids[0]
  vpc_security_group_ids = [
    aws_security_group.internal_traffic.id,
    aws_security_group.k8s_control_plane.id,
    data.tfe_outputs.vpc.values.tailscale.security_group.id
  ]
  tags = {
    "Name"                                                = "${local.configs.cluster_name}-k8s-control-plane"
    "kubernetes.io/cluster/${local.configs.cluster_name}" = "owned"
  }
  metadata_options {
    http_endpoint = "enabled"
    # instance_metadata_tags = "enabled"
  }
  root_block_device {
    encrypted   = false
    volume_size = 25
    volume_type = "gp3"
  }
}
