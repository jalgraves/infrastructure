# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  development-aws-vpc-use2 = {
    assign_generated_ipv6_cidr_block = true
    # Two subnets (one public, one private) will be created for each AZ passed in
    availability_zones = ["us-east-2a", "us-east-2b"]
    cdn = {
      aliases = []
      enabled = false
    }
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"
    env                  = "development"
    ipv4 = {
      cidr_block                                  = "10.8.0.0/16"
      destination_cidr_block                      = "0.0.0.0/0"
      enable_resource_name_dns_a_record_on_launch = false
      netmask_length                              = 16
    }
    ipv6 = {
      assign_ipv6_address_on_creation                = false
      destination_cidr_block                         = "64:ff9b::/96"
      enable_dns64                                   = false
      enable_resource_name_dns_aaaa_record_on_launch = false
    }
    max_nats                            = 1
    private_dns_hostname_type_on_launch = "ip-name"
    region                              = "us-east-2"
    # region_code is part of naming convention used to build hostnames and name other resources
    region_code = "use2"
    tailscale = {
      enabled       = true
      instance_type = "t3.nano"
    }
  }
}
