# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "aws_region" "current" {}

resource "aws_vpc_ipam" "this" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool" "ipv4" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.this.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "ipv4" {
  ipam_pool_id = aws_vpc_ipam_pool.ipv4.id
  cidr         = local.configs.ipv4.cidr_block
}

resource "aws_vpc" "this" {
  ipv4_ipam_pool_id                = aws_vpc_ipam_pool.ipv4.id
  ipv4_netmask_length              = local.configs.ipv4.netmask_length
  instance_tenancy                 = local.configs.instance_tenancy
  enable_dns_hostnames             = local.configs.enable_dns_hostnames
  enable_dns_support               = local.configs.enable_dns_support
  assign_generated_ipv6_cidr_block = local.configs.assign_generated_ipv6_cidr_block
  tags = {
    Name = "${local.configs.env}-${local.configs.region_code}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.configs.env}-${local.configs.region_code}"
  }
}

resource "aws_eip" "this" {
  tags = {
    Name = "${local.configs.env}-${local.configs.region_code}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "default" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  az_count           = length(data.aws_availability_zones.default.names)
  bits               = ceil(log(local.az_count, 2)) * 4
  ipv4_cidrs         = [for index in range(4) : cidrsubnet(aws_vpc_ipam_pool_cidr.ipv4.cidr, local.bits, index)]
  ipv6_cidrs         = [for index in range(4) : cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, index)]
  public_ipv4_cidrs  = slice(local.ipv4_cidrs, 0, 2)
  private_ipv4_cidrs = slice(local.ipv4_cidrs, 2, 4)
  public_ipv6_cidrs  = slice(local.ipv6_cidrs, 0, 2)
  private_ipv6_cidrs = slice(local.ipv6_cidrs, 2, 4)
}
