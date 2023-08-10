# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_subnet" "private" {
  count                                          = length(local.configs.availability_zones)
  vpc_id                                         = aws_vpc.this.id
  availability_zone                              = local.configs.availability_zones[count.index]
  cidr_block                                     = local.private_ipv4_cidrs[count.index]
  ipv6_cidr_block                                = local.private_ipv6_cidrs[count.index]
  assign_ipv6_address_on_creation                = false
  enable_dns64                                   = true
  enable_resource_name_dns_a_record_on_launch    = local.configs.ipv4.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = local.configs.ipv6.enable_resource_name_dns_aaaa_record_on_launch
  private_dns_hostname_type_on_launch            = local.configs.private_dns_hostname_type_on_launch
  tags = {
    "Name"                                                                    = "${local.configs.env}-${local.configs.region_code}-private-${count.index}"
    "kubernetes.io/cluster/${local.configs.env}-${local.configs.region_code}" = "owned"
    "kubernetes.io/role/internal-elb"                                         = "1"
    "cpco.io/subnet/type"                                                     = "private"
  }
  lifecycle {
    # Ignore tags added by kops or kubernetes
    ignore_changes = [tags.kubernetes, tags.SubnetType]
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${local.configs.env}-${local.configs.region_code}-private"
  }
}

resource "aws_egress_only_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "private6" {
  route_table_id              = aws_route_table.private.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.this.id
  destination_cidr_block = local.configs.ipv4.destination_cidr_block
  depends_on             = [aws_route_table.private]
}

resource "aws_route_table_association" "private" {
  count          = length(local.configs.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id

  tags = {
    "Name" = "${local.configs.env}-${local.configs.region_code}-private"
  }
}

resource "aws_network_acl_rule" "private4_ingress" {
  network_acl_id = aws_network_acl.private.id
  rule_action    = "allow"
  rule_number    = 100

  egress     = false
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
}

resource "aws_network_acl_rule" "private4_egress" {
  network_acl_id = aws_network_acl.private.id
  rule_action    = "allow"
  rule_number    = 100

  egress     = true
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
}

resource "aws_network_acl_rule" "private6_ingress" {
  network_acl_id = aws_network_acl.private.id
  rule_action    = "allow"
  rule_number    = 111

  egress          = false
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
}

resource "aws_network_acl_rule" "private6_egress" {
  network_acl_id = aws_network_acl.private.id
  rule_action    = "allow"
  rule_number    = 111

  egress          = true
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
}
