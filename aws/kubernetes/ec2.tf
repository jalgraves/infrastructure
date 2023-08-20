# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "cluster" {
  name_prefix = "${local.configs.cluster_name}-k8s-"
}

locals {
  cert_arns = concat([data.tfe_outputs.route53.values.acm.certificates.env.arn], data.tfe_outputs.certs[0].values.acm.certificates.client_domain_arns)

  template_vars = {
    anonymous_auth_enabled                = local.configs.k8s.anonymous_auth_enabled
    app_secret_name                       = aws_secretsmanager_secret.app_creds.name
    api_port                              = var.api_port
    argocd_enabled                        = local.configs.k8s.argocd_enabled
    asg_name                              = aws_autoscaling_group.kubernetes_cluster_autoscaler.name
    automated_user                        = var.automated_user
    availability_zones                    = join(",", data.tfe_outputs.vpc.values.subnets.availability_zones)
    aws_access_key_id                     = aws_iam_access_key.kubernetes_cluster_autoscaler.id,
    aws_account_id                        = data.aws_caller_identity.current.account_id
    aws_external_dns_enabled              = local.configs.aws_external_dns.enabled
    aws_external_dns_replicas             = local.configs.aws_external_dns.replicas
    aws_load_balancer_controller_enabled  = local.configs.aws_load_balancer_controller.enabled
    aws_load_balancer_controller_replicas = local.configs.aws_load_balancer_controller.replicas
    aws_secret_access_key                 = aws_iam_access_key.kubernetes_cluster_autoscaler.secret
    beantown_secret_name                  = aws_secretsmanager_secret.beantown_creds.name
    contact_api_secret_name               = aws_secretsmanager_secret.contact_api_creds.name
    cert_arns                             = join(",", local.cert_arns)
    cert_manager_enabled                  = local.configs.k8s.cert_manager_enabled
    cgroup_driver                         = local.configs.k8s.cgroup_driver
    cilium_cidr                           = local.configs.cilium.cidr
    cilium_version                        = local.configs.cilium.version
    cloud_provider                        = local.configs.k8s.cloud_provider
    cluster_autoscaler_enabled            = local.configs.k8s.cluster_autoscaler_enabled
    cluster_cidr                          = local.configs.k8s.cluster_cidr
    cluster_domain                        = var.cluster_domain
    cluster_name                          = local.configs.cluster_name
    control_plane_endpoint                = var.control_plane_endpoint
    database_secret_name                  = aws_secretsmanager_secret.database_creds.name
    ebs_csi_driver_enabled                = local.configs.k8s.ebs_csi_driver_enabled
    env                                   = local.configs.env
    external_dns_enabled                  = local.configs.k8s.external_dns_enabled
    gateway_domains                       = join(",", var.gateway_domains)
    github_ssh_secret                     = var.github_ssh_secret
    istio_enabled                         = local.configs.k8s.istio_enabled
    karpenter_enabled                     = local.configs.karpenter.enabled
    karpenter_instance_profile            = module.iam.karpenter.instance_profile.name
    karpenter_replicas                    = local.configs.karpenter.replicas
    karpenter_service_account_role_arn    = module.iam.karpenter.role.arn
    karpenter_version                     = local.configs.karpenter.version
    kubelet_authorization_mode            = local.configs.k8s.kubelet_authorization_mode
    kubelet_tls_bootstrap_enabled         = local.configs.k8s.kubelet_tls_bootstrap_enabled
    kubernetes_version                    = local.configs.k8s.version
    metrics_server_enabled                = local.configs.k8s.metrics_server_enabled
    org                                   = var.org
    pod_identity_webhook_enabled          = local.configs.k8s.pod_identity_webhook_enabled
    region                                = local.configs.region
    region_code                           = local.configs.region_code
    secret_arn                            = aws_secretsmanager_secret.cluster.arn
    sa_signer_key                         = var.sa_signer_key
    sa_signer_pkcs8_pub                   = var.sa_signer_pkcs8_pub
    service_account_issuer_url            = "https://${module.irsa.oidc.issuer}"
    ssh_public_key                        = var.ssh_public_key
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

resource "aws_key_pair" "k8s_cluster" {
  key_name   = "${local.configs.env}-${local.configs.region_code}-k8s-cluster-key-pair"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGkkKlhgtzhJob2Q67MSjpV0L1rmmnkay05IS1KUm2Hp"
}

resource "aws_instance" "k8s_control_plane" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = local.configs.ec2.instance_type
  user_data                   = local.k8s_control_plane_user_data
  iam_instance_profile        = module.iam.k8s_control_plane.instance_profile.name
  associate_public_ip_address = false
  #key_name                    = data.tfe_outputs.vpc.values.tailscale.key_pair.name
  key_name = aws_key_pair.k8s_cluster.id
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
  depends_on = [
    aws_s3_object.kubeadm_init
  ]
}

resource "aws_route53_record" "k8s" {
  zone_id = data.tfe_outputs.route53.values.route53.zones.region.id
  name    = "k8s"
  type    = "A"
  ttl     = 30
  records = [aws_instance.k8s_control_plane.private_ip]
}

resource "aws_instance" "worker" {
  count = 0
  #ami                         = "ami-0e90ad145bf05c564"
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.medium"
  iam_instance_profile        = module.iam.k8s_worker.instance_profile.name
  associate_public_ip_address = false
  key_name                    = data.tfe_outputs.vpc.values.tailscale.key_pair.name
  subnet_id                   = data.tfe_outputs.vpc.values.subnets.private.ids[0]
  vpc_security_group_ids = [
    aws_security_group.internal_traffic.id,
    aws_security_group.k8s_control_plane.id,
    data.tfe_outputs.vpc.values.tailscale.security_group.id
  ]
  tags = {
    "Name"                                                = "${local.configs.cluster_name}-k8s-worker"
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
  depends_on = [
    aws_s3_object.kubeadm_init
  ]
}
