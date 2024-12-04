# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# These resources pull data from other TFC workspaeces. The values are used to
# build other resources within the currently running workspace.
# https://www.terraform.io/cloud-docs/workspaces/state#accessing-state-from-other-workspaces
# The EKS resources being created in the running workspace require that resources from the
# below tfe_output workspaces have already been applied

data "tfe_outputs" "vpc" {
  organization = "jalgraves"
  workspace    = "${local.configs.env}-aws-vpc-${local.configs.region_code}"
}

data "tfe_outputs" "certs" {
  count        = local.configs.env == "production" ? 1 : 0
  organization = "jalgraves"
  workspace    = "${local.configs.env}-aws-route53-${local.configs.region_code}"
}

data "tfe_outputs" "route53" {
  organization = "jalgraves"
  workspace    = "${local.configs.env}-aws-route53-${local.configs.region_code}"
}
