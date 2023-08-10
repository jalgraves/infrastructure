# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-*-gp2"]
  }
}

locals {
  tailscale_template_vars = {
    subnets_to_advertise = join(",", local.private_ipv4_cidrs),
    tailscale_auth_key   = var.tailscale_auth_key
  }
  tailscale_rendered_template = templatefile("${path.cwd}/templates/tailscale_subnet_router_user_data.sh", local.tailscale_template_vars)
}

resource "aws_key_pair" "tailscale" {
  key_name   = "${local.configs.env}-${local.configs.region_code}-tailscale-key-pair"
  public_key = var.tailscale_public_ssh_key
}

resource "aws_instance" "tailscale_subnet_router" {
  count                       = local.configs.tailscale.enabled ? 1 : 0
  ami                         = data.aws_ami.amazon_linux2.id
  associate_public_ip_address = true
  ebs_optimized               = true
  instance_type               = local.configs.tailscale.instance_type
  key_name                    = aws_key_pair.tailscale.key_name
  vpc_security_group_ids = [
    aws_security_group.tailscale[0].id
  ]
  subnet_id = aws_subnet.public[0].id
  user_data = local.tailscale_rendered_template
  tags = {
    Name = "${local.configs.env}-${local.configs.region_code}-tailscale-subnet-router"
  }
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    encrypted   = false
    volume_size = 8
    volume_type = "gp3"
  }
}

resource "aws_security_group" "tailscale" {
  count       = local.configs.tailscale.enabled ? 1 : 0
  name        = "${local.configs.env}-${local.configs.region_code}-tailscale-subnet-router-traffic"
  description = "Allow outbound traffic. Created via Terraform workspace ${terraform.workspace}"
  vpc_id      = aws_vpc.this.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3222
    to_port     = 3222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow egress to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.configs.env}-${local.configs.region_code}-tailscale-subnet-router-traffic"
  }
}
