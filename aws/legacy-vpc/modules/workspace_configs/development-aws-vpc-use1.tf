# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  development-aws-vpc-use1 = {
    assign_generated_ipv6_cidr_block = true
    # Two subnets (one public, one private) will be created for each AZ passed in
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    cdn = {
      aliases = ["cdn.jalgraves.us-east-1.jalgraves.com"]
    }
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"
    env                  = "development"
    ipv4 = {
      cidr_block                                  = "10.7.0.0/16"
      destination_cidr_block                      = "0.0.0.0/0"
      enable_resource_name_dns_a_record_on_launch = false
      netmask_length                              = 16
    }
    ipv6 = {
      assign_ipv6_address_on_creation                = false
      destination_cidr_block                         = "64:ff9b::/96"
      enable_resource_name_dns_aaaa_record_on_launch = false
    }
    max_nats                            = 1
    private_dns_hostname_type_on_launch = "ip-name"
    region                              = "us-east-1"
    # region_code is part of naming convention used to build hostnames and name other resources
    region_code = "use1"
  }
}
