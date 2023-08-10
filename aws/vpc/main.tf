# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "configs" {
  source = "./modules/workspace_configs"

  workspace = terraform.workspace
}

data "aws_region" "current" {}

locals {
  az_count           = length(data.aws_availability_zones.default.names)
  configs            = module.configs.values
  bits               = ceil(log(local.az_count, 2)) * 2
  ipv4_cidrs         = [for index in range(4) : cidrsubnet(aws_vpc.this.cidr_block, local.bits, index)]
  ipv6_cidrs         = [for index in range(4) : cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, index)]
  public_ipv4_cidrs  = slice(local.ipv4_cidrs, 0, 2)
  private_ipv4_cidrs = slice(local.ipv4_cidrs, 2, 4)
  public_ipv6_cidrs  = slice(local.ipv6_cidrs, 0, 2)
  private_ipv6_cidrs = slice(local.ipv6_cidrs, 2, 4)
}

resource "aws_vpc" "this" {
  cidr_block                       = local.configs.ipv4.cidr_block
  instance_tenancy                 = local.configs.instance_tenancy
  enable_dns_hostnames             = local.configs.enable_dns_hostnames
  enable_dns_support               = local.configs.enable_dns_support
  assign_generated_ipv6_cidr_block = local.configs.assign_generated_ipv6_cidr_block
  tags = {
    "Name" = "${local.configs.env}-${local.configs.region_code}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${local.configs.env}-${local.configs.region_code}"
  }
}

resource "aws_eip" "this" {
  tags = {
    "Name" = "${local.configs.env}-${local.configs.region_code}"
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
