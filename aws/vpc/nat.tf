# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${local.configs.env}-${local.configs.region_code}"
  }
}

# resource "aws_route" "nat4" {
#   route_table_id         = aws_route_table.public.id
#   nat_gateway_id         = aws_nat_gateway.this.id
#   destination_cidr_block = local.configs.ipv4.destination_cidr_block
#   depends_on             = [aws_route_table.private]
# }

resource "aws_route" "private_nat64" {
  route_table_id              = aws_route_table.private.id
  nat_gateway_id              = aws_nat_gateway.this.id
  destination_ipv6_cidr_block = local.configs.ipv6.destination_cidr_block
  depends_on                  = [aws_route_table.private]
}

# resource "aws_route" "public_nat64" {
#   route_table_id              = aws_route_table.public.id
#   nat_gateway_id              = aws_nat_gateway.this.id
#   destination_ipv6_cidr_block = local.configs.ipv6.destination_cidr_block
#   depends_on                  = [aws_route_table.public]
# }
