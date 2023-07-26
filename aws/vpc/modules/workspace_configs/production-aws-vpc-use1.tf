# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

locals {
  production-aws-vpc-use1 = {
    # Two subnets (one public, one privaate) will be created for each AZ passed in
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    cluster_name       = "production-use1"
    env                = "production"
    # max_nats: the maximim of nat gateways to use for the VPC. Minimum 1 but after that
    # number cannot exceed the number of availability zones (AZs)
    max_nats = 3
    region   = "us-east-1"
    # region_code is part of naming convention used to build hostnames and name other resources
    region_code = "use1"
    vpc_cidr    = "10.12.0.0/16"
  }
}
