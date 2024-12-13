# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "owner-id"
    values = ["137112412989"] # Amazon's official owner ID
  }
  owners = ["137112412989"] # Ensure the AMI is from the official Amazon account
}

resource "tls_private_key" "ec2_key" {
  for_each = {
    for instance_name, instance in local.configs.instances : instance_name => instance
  }
  algorithm = "RSA"
  rsa_bits  = 2048
}

# resource "aws_secretsmanager_secret_version" "ec2_key" {
#   for_each = {
#     for instance_name, instance in local.configs.instances : instance_name => instance
#   }
#   secret_id = "${local.configs.cluster_name}/ec2/${each.key}"
#   secret_string = jsonencode(
#     {
#       public_key_openssh  = tls_private_key.ec2_key.public_key_openssh
#       private_key_openssh = tls_private_key.ec2_key.private_key_openssh
#     }
#   )
# }

locals {
  dns_zones = {
    control-plane = join(".", slice(split(".", var.control_plane_endpoint), 1, length(split(".", var.control_plane_endpoint))))
  }
  user_data_template_values = {
    control-plane = {
      cluster_name           = local.configs.cluster_name
      environment            = local.configs.environment
      external_dns_domain    = local.configs.instances["control-plane"].external_dns_domain
      kubernetes_version     = "1.31.0"
      control_plane_port     = var.control_plane_port
      control_plane_endpoint = var.control_plane_endpoint
      service_subnet         = var.service_subnet
    }
  }
}

resource "aws_key_pair" "this" {
  for_each = {
    for instance_name, instance in local.configs.instances : instance_name => instance
  }
  key_name   = "${local.configs.cluster_name}-${each.key}"
  public_key = tls_private_key.ec2_key[each.key].public_key_openssh
}

resource "aws_instance" "this" {
  for_each = {
    for instance_name, instance in local.configs.instances : instance_name => instance
  }
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = each.value.instance_type
  user_data                   = templatefile("${path.module}/templates/${each.value.user_data_script}", local.user_data_template_values[each.key])
  user_data_replace_on_change = each.value.user_data_replace_on_change
  iam_instance_profile        = each.value.iam_instance_profile
  associate_public_ip_address = each.value.associate_public_ip_address
  key_name                    = aws_key_pair.this[each.key].key_name
  subnet_id                   = each.value.associate_public_ip_address ? data.terraform_remote_state.vpc.outputs.subnets.public.ids[0] : data.terraform_remote_state.vpc.outputs.subnets.private.ids[0]
  vpc_security_group_ids = [
    aws_security_group.internal_traffic.id,
    aws_security_group.k8s_control_plane.id
  ]
  tags = {
    "Name"                                                = "${local.configs.cluster_name}-k8s-control-plane"
    "kubernetes.io/cluster/${local.configs.cluster_name}" = "owned"
  }
  metadata_options {
    http_endpoint = each.value.http_endpoint
    # instance_metadata_tags = "enabled"
  }
  root_block_device {
    encrypted   = each.value.root_block_device.encrypted
    volume_size = each.value.root_block_device.volume_size
    volume_type = each.value.root_block_device.volume_type
  }
  depends_on = [
  ]
}

resource "aws_route53_record" "ec2" {
  for_each = {
    for instance_name, instance in local.configs.instances : instance_name => instance
  }

  allow_overwrite = true
  name            = each.key
  records         = [aws_instance.this[each.key].public_ip]
  ttl             = 5
  type            = "A"
  zone_id         = data.terraform_remote_state.route53.outputs.dns.zones[local.dns_zones[each.key]].id
}

resource "aws_route53_record" "ec2_ipv6" {
  for_each = {
    for instance_name, instance in local.configs.instances : instance_name => instance
  }

  allow_overwrite = true
  name            = each.key
  records         = [aws_instance.this[each.key].ipv6_addresses[0]]
  ttl             = 5
  type            = "AAAA"
  zone_id         = data.terraform_remote_state.route53.outputs.dns.zones[local.dns_zones[each.key]].id
}
