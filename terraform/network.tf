resource "aws_vpc" "prod" {
  cidr_block           = var.base_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "jpc-prod"
    region      = var.aws_region
    provisioner = "terraform"
  }
}

resource "aws_internet_gateway" "prod_gateway" {
  vpc_id = aws_vpc.prod.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.prod.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.prod_gateway.id
}

resource "aws_subnet" "jalnet_ops" {
  vpc_id                  = aws_vpc.prod.id
  availability_zone       = "us-east-2a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name        = "jalnet-ops"
    region      = var.aws_region
    provisioner = "terraform"
  }
}

resource "aws_subnet" "jalnet_private_2b" {
  vpc_id                  = aws_vpc.prod.id
  availability_zone       = "us-east-2b"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name        = "jalnet-2a"
    region      = var.aws_region
    provisioner = "terraform"
  }
}

resource "aws_subnet" "jalnet_private_2c" {
  vpc_id                  = aws_vpc.prod.id
  availability_zone       = "us-east-2c"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name        = "jalnet-2b"
    region      = var.aws_region
    provisioner = "terraform"
  }
}