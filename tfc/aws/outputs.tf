# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

output "workspace_ids" {
  value = {
    for region in local.configs.region_codes : "${local.configs.env}-aws-${local.configs.directory}-${region}" => {
      id = tfe_workspace.this[region].id
    }
  }
}
