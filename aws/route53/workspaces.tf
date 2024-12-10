# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

module "configs" {
  # These are the environment specific configurations defined in each seperate .tf file
  # in ./modules/workspace_configs
  source    = "./modules/workspace_configs"
  workspace = terraform.workspace
}

locals {
  configs = module.configs.values
}
