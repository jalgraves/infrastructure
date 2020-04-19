resource "aws_vpc" "prod" {
  cidr_block           = var.base_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name         = "prod-vpc"
    region       = var.aws_region
    aws-resource = "vpc"
    provisioner  = "terraform"
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

resource "aws_subnet" "jal_subnet_public" {
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name         = "jke-subnet-public"
    region       = var.aws_region
    aws-resource = "subnet"
    provisioner  = "terraform"
  }
}

resource "aws_subnet" "jal_subnet_public_2a" {
  vpc_id                  = aws_vpc.prod.id
  availability_zone       = "us-east-2a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name         = "jke-subnet-public-2a"
    region       = var.aws_region
    aws-resource = "subnet"
    provisioner  = "terraform"
  }
}