# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_security_group" "internal_traffic" {
  name_prefix = local.configs.cluster_name
  description = "Allow private subnet traffic within vpc. Created via Terraform workspace ${terraform.workspace}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc.id

  # TODO: Break this down to more granular rules
  ingress {
    description = "Allow all traffic within the private CIDR. Created via Terraform workspace ${terraform.workspace}"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "172.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name                                                  = "${local.configs.cluster_name}-internal-traffic"
    "k8s.io/cluster/${local.configs.cluster_name}"        = "owned"
    "kubernetes.io/cluster/${local.configs.cluster_name}" = "owned"
  }
}

resource "aws_security_group" "k8s_control_plane" {
  name        = "${local.configs.cluster_name}-k8s-control-plane"
  description = "Allow traffic to K8s API. Created via Terraform workspace ${terraform.workspace}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc.id
  ingress {
    description = "Allow traffic to K8s API. Created via Terraform workspace ${terraform.workspace}"
    from_port   = var.control_plane_port
    to_port     = var.control_plane_port
    protocol    = "tcp"
    cidr_blocks = var.control_plane_allowed_ips
  }
  ingress {
    description = "Allow access to control plane from certain IPs. Created via Terraform workspace ${terraform.workspace}"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.control_plane_allowed_ips
  }
  tags = {
    Name                                           = "${local.configs.cluster_name}-k8s-control-plane"
    "k8s.io/cluster/${local.configs.cluster_name}" = "owned"
  }
}
