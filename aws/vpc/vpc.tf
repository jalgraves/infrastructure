# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "vpc" {
  source = "git::https://github.com/jalgraves/terraform-aws-vpc?ref=19b5833d1f2427e9d20d5ac91127be211ea7c01c"

  availability_zones = local.configs.azs
  ipv4               = local.configs.ipv4
  ipv6               = local.configs.ipv6
  env                = local.configs.environment
  region             = local.configs.region
  region_code        = local.configs.region_code
  subnet_tags        = local.configs.vpc_subnet_tags
}
