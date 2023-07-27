# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_security_group" "internal_traffic" {
  name        = "${local.configs.cluster_name}-internal-traffic"
  description = "Allow private subnet traffic within vpc. Created via Terraform workspace ${terraform.workspcace}"
  vpc_id      = data.tfe_outputs.vpc.values.vpc.vpc_id

  # TODO: Break this down to more granular rules
  ingress {
    description = "Allow all traffic within the private CIDR. Created via Terraform workspace ${terraform.workspcace}"
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
    Name                                                   = "${local.configs.cluster_name}-internal-traffic"
    "k8s.io/cluster/${local.configs.cluster_name}"         = "owned"
    "karpenter.sh/discovery/${local.configs.cluster_name}" = local.configs.cluster_name
  }
}
