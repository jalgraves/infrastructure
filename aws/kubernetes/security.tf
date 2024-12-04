# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_security_group" "internal_traffic" {
  name        = "${local.configs.cluster_name}-internal-traffic"
  description = "Allow private subnet traffic within vpc. Created via Terraform workspace ${terraform.workspace}"
  vpc_id      = data.tfe_outputs.vpc.values.vpc.id

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
    Name                                                   = "${local.configs.cluster_name}-internal-traffic"
    "k8s.io/cluster/${local.configs.cluster_name}"         = "owned"
    "karpenter.sh/discovery/${local.configs.cluster_name}" = local.configs.cluster_name
    "kubernetes.io/cluster/${local.configs.cluster_name}"  = "owned"
  }
}

resource "aws_security_group" "k8s_control_plane" {
  name        = "${local.configs.cluster_name}-k8s-control-plane"
  description = "Allow traffic to K8s API. Created via Terraform workspace ${terraform.workspace}"
  vpc_id      = data.tfe_outputs.vpc.values.vpc.id
  ingress {
    description = "Allow traffic to K8s API. Created via Terraform workspace ${terraform.workspace}"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow from work office. Created via Terraform workspace ${terraform.workspace}"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["50.231.13.130/32"]
  }
  tags = {
    Name                                           = "${local.configs.cluster_name}-k8s-control-plane"
    "k8s.io/cluster/${local.configs.cluster_name}" = "owned"
  }
}
