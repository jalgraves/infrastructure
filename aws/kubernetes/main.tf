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

module "irsa" {
  source = "./modules/irsa"

  cluster_name = local.configs.cluster_name
  oidc_jwks    = var.oidc_jwks
  org          = local.configs.org
  #sha1_fingerprint = var.sha1_fingerprint
}

module "iam" {
  source = "./modules/iam"

  cluster_name = local.configs.cluster_name
  env          = local.configs.env
  region       = local.configs.region
  region_code  = local.configs.region_code
  oidc = {
    issuer       = module.irsa.oidc.issuer
    provider_arn = module.irsa.oidc.provider.arn
  }
}
