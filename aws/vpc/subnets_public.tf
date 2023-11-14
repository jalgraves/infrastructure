# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_subnet" "public" {
  count                                          = length(local.configs.availability_zones)
  vpc_id                                         = aws_vpc.this.id
  availability_zone                              = local.configs.availability_zones[count.index]
  cidr_block                                     = local.public_ipv4_cidrs[count.index]
  ipv6_cidr_block                                = local.public_ipv6_cidrs[count.index]
  assign_ipv6_address_on_creation                = local.configs.ipv6.assign_ipv6_address_on_creation
  enable_dns64                                   = local.configs.ipv6.enable_dns64
  map_public_ip_on_launch                        = true
  enable_resource_name_dns_a_record_on_launch    = local.configs.ipv4.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = local.configs.ipv6.enable_resource_name_dns_aaaa_record_on_launch
  private_dns_hostname_type_on_launch            = local.configs.private_dns_hostname_type_on_launch
  tags = {
    "Name"                                                                    = "${local.configs.env}-${local.configs.region_code}-public-${count.index}"
    "kubernetes.io/cluster/${local.configs.env}-${local.configs.region_code}" = "owned"
    "kubernetes.io/role/elb"                                                  = "1"
    "cpco.io/subnet/type"                                                     = "public"
  }
  lifecycle {
    # Ignore tags added by kops or kubernetes
    ignore_changes = [tags.kubernetes, tags.SubnetType]
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${local.configs.env}-${local.configs.region_code}-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(local.configs.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public[*].id

  tags = {
    "Name" = "${local.configs.env}-${local.configs.region_code}-public"
  }
}

resource "aws_network_acl_rule" "public4_ingress" {
  network_acl_id = aws_network_acl.public.id
  rule_action    = "allow"
  rule_number    = 100

  egress     = false
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
}

resource "aws_network_acl_rule" "public4_egress" {
  network_acl_id = aws_network_acl.public.id
  rule_action    = "allow"
  rule_number    = 100

  egress     = true
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
}

resource "aws_network_acl_rule" "public6_ingress" {
  network_acl_id = aws_network_acl.public.id
  rule_action    = "allow"
  rule_number    = 111

  egress          = false
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
}

resource "aws_network_acl_rule" "public6_egress" {
  network_acl_id = aws_network_acl.public.id
  rule_action    = "allow"
  rule_number    = 111

  egress          = true
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = local.configs.ipv4.destination_cidr_block
  depends_on             = [aws_route_table.public]
}
