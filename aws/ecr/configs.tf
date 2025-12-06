module "configs" {
  source = "./modules/workspace_configs"

  workspace = terraform.workspace
}

locals {
  configs = module.configs.values
}
