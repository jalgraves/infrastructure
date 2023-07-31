

# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "configs" {
  source = "./modules/workspace_configs"

  workspace = terraform.workspace
}

locals {
  configs = module.configs.values
}

module "iam" {
  source = "./modules/iam"

  cluster_name = local.config.cluster_name
  env          = local.configs.env
  region       = local.configs.region
  region_code  = local.configs.region_code
}
