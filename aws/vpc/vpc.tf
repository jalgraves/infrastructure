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

resource "aws_vpc_ipam_pool" "ipv6" {
  address_family = "ipv6"
  ipam_scope_id  = aws_vpc_ipam.this.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "ipv6" {
  ipam_pool_id = aws_vpc_ipam_pool.ipv6.id
  cidr         = local.configs.ipv6.cidr_block
}

resource "aws_vpc" "this" {
  ipv4_ipam_pool_id                = aws_vpc_ipam_pool.ipv4.id
  ipv4_netmask_length              = local.configs.ipv4.netmask_length
  ipv6_ipam_pool_id                = aws_vpc_ipam_pool.ipv6.id
  ipv6_netmask_length              = local.configs.ipv6.netmask_length
  instance_tenancy                 = local.configs.instance_tenancy
  enable_dns_hostnames             = local.configs.enable_dns_hostnames
  enable_dns_support               = local.configs.enable_dns_support
  assign_generated_ipv6_cidr_block = local.configs.assign_generated_ipv6_cidr_block
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
