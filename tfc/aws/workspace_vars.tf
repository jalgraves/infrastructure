# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
resource "tfe_variable" "aws_account_id" {
  for_each = {
    for k, v in toset(local.configs.region_codes) : k => v
    if local.configs.directory == "kubernetes"
  }
  key          = "aws_account_id"
  value        = var.aws_account_id
  category     = "terraform"
  workspace_id = tfe_workspace.this[each.value].id
  description  = "AWS account ID. Created via Terraform workspace ${terraform.workspace}"
  sensitive    = true
}

resource "tfe_variable" "domain_name" {
  for_each = {
    for k, v in toset(local.configs.region_codes) : k => v
    if local.configs.directory == "kubernetes"
  }
  key          = "domain_name"
  value        = var.domain_name
  category     = "terraform"
  workspace_id = tfe_workspace.this[each.value].id
  description  = "K8s cluster domain name. Created via Terraform workspace ${terraform.workspace}"
  sensitive    = true
}

resource "tfe_variable" "tfc_token" {
  for_each = {
    for k, v in toset(local.configs.region_codes) : k => v
    if local.configs.use_tfc
  }
  key          = "tfc_token"
  value        = var.tfc_token
  category     = "terraform"
  workspace_id = tfe_workspace.this[each.value].id
  description  = "TFC api token. Created via Terraform workspace ${terraform.workspace}"
  sensitive    = true
}

resource "tfe_variable" "tailscale_auth_key" {
  for_each = {
    for k, v in toset(local.configs.region_codes) : k => v
    if local.configs.directory == "vpc"
  }
  key          = "tailscale_auth_key"
  value        = var.tfc_token
  category     = "terraform"
  workspace_id = tfe_workspace.this[each.value].id
  description  = "Tailscale auth key for subnet-router. Created via Terraform workspace ${terraform.workspace}"
  sensitive    = true
}

resource "tfe_variable" "tailscale_public_ssh_key" {
  for_each = {
    for k, v in toset(local.configs.region_codes) : k => v
    if local.configs.directory == "vpc"
  }
  key          = "tailscale_public_ssh_key"
  value        = var.tfc_token
  category     = "terraform"
  workspace_id = tfe_workspace.this[each.value].id
  description  = "Public key for creating SSH private for Tailscale subnet-router. Created via Terraform workspace ${terraform.workspace}"
  sensitive    = true
}
