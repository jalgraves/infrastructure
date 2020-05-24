resource "aws_vpc" "prod" {
  cidr_block           = var.base_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name         = "jpc-prod"
    region       = var.aws_region
    provisioner  = "terraform"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name = "jalnet-internet-gw"
    provisioner  = "terraform"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.jalnet_public.id
  tags = {
    Name = "jalnet-nat-gw"
    provisioner  = "terraform"
  }
  depends_on = [aws_internet_gateway.internet_gw]
}

resource "aws_route_table" "jalnet_rtbl" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name         = "jalnet-rtbl"
    region       = var.aws_region
    provisioner  = "terraform"
  }
}

resource "aws_route" "to_nat_gw" {
  route_table_id         = aws_route_table.jalnet_rtbl.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.nat_gw.id
}

resource "aws_route" "to_internet_gw" {
  route_table_id         = aws_vpc.prod.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

resource "aws_route_table_association" "jalnet_rtbl_assoc" {
  subnet_id     = aws_subnet.jalnet_private_2b.id
  route_table_id = aws_route_table.jalnet_rtbl.id
}

resource "aws_subnet" "jalnet_public" {
  vpc_id                  = aws_vpc.prod.id
  availability_zone       = "us-east-2a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name         = "jalnet-public"
    region       = var.aws_region
    provisioner  = "terraform"
  }
}

resource "aws_subnet" "jalnet_private_2b" {
  vpc_id                  = aws_vpc.prod.id
  availability_zone       = "us-east-2b"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name         = "jalnet-pri-az2b"
    region       = var.aws_region
    provisioner  = "terraform"
  }
}

resource "aws_subnet" "jalnet_private_2c" {
  vpc_id                  = aws_vpc.prod.id
  availability_zone       = "us-east-2c"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name         = "jalnet-pri-az2c"
    region       = var.aws_region
    provisioner  = "terraform"
  }
}