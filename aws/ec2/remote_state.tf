# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = local.configs.remote_bucket_name
    key    = "env:/${local.configs.environment}-aws-vpc-${local.configs.region_code}/vpc/${local.configs.cluster_name}.tfstate"
    region = local.configs.region
  }
}

data "terraform_remote_state" "route53" {
  backend = "s3"
  config = {
    bucket = local.configs.remote_bucket_name
    key    = "env:/${local.configs.environment}-aws-route53-${local.configs.region_code}/route53/${local.configs.cluster_name}.tfstate"
    region = local.configs.region
  }
}
