locals {
  configs = {
    env         = "production"
    region      = "us-east-1"
    region_code = "use1"
  }
  azs = {
    # Availability zones
    us-east-1a = {
      nat_gateway_enabled            = false
      public_route_table_enabled     = true
      public_route_table_association = null
    }
  }
  ipv4 = {
    bits                                        = 2
    cidr_block                                  = "10.0.0.0/16"
    destination_cidr_block                      = "0.0.0.0/0"
    enable_resource_name_dns_a_record_on_launch = true
  }
  ipv6 = {
    bits                                           = 8
    assign_ipv6_address_on_creation                = true
    destination_cidr_block                         = "64:ff9b::/96"
    enabled                                        = true
    enable_dns64                                   = true
    enable_resource_name_dns_aaaa_record_on_launch = true
  }
  vpc_subnet_tags = {
    public = {
      "kubernetes.io/cluster/${local.configs.env}-${local.configs.region_code}" = "owned"
      "kubernetes.io/role/elb"                                                  = "1"
      "cpco.io/subnet/type"                                                     = "public"
    }
    private = {
      "kubernetes.io/cluster/test-use2" = "owned"
      "kubernetes.io/role/internal-elb" = "1"
      "cpco.io/subnet/type"             = "private"
    }
  }
}

module "vpc" {
  source = "git::https://github.com/jalgraves/terraform-aws-vpc?ref=19b5833d1f2427e9d20d5ac91127be211ea7c01c"

  availability_zones = local.azs
  ipv4               = local.ipv4
  ipv6               = local.ipv6
  env                = local.configs.env
  region             = local.configs.region
  region_code        = local.configs.region_code
  subnet_tags        = local.vpc_subnet_tags
}
