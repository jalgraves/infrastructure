# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# Configs specific to the workspace production-aws-iam-use1

locals {
  production-aws-vpc-use1 = {
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"
    azs = {
      # Availability zones
      us-east-1a = {
        nat_gateway_enabled            = false
        public_route_table_enabled     = true
        public_route_table_association = null
      }
      us-east-1b = {
        nat_gateway_enabled            = false
        public_route_table_enabled     = false
        public_route_table_association = "us-east-1a"
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
        "kubernetes.io/cluster/production-use1" = "owned"
        "kubernetes.io/role/elb"                = "1"
        "cpco.io/subnet/type"                   = "public"
      }
      private = {
        "kubernetes.io/cluster/production-use1" = "owned"
        "kubernetes.io/role/internal-elb"       = "1"
        "cpco.io/subnet/type"                   = "private"
      }
    }
  }
}
