# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

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
