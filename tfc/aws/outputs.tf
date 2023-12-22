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

output "global_workspaces" {
  value = length(local.configs.region_codes) == 0 ? {
    for workspace in tfe_workspace.global[*] : workspace.name => {
      id                = workspace.id
      project_id        = workspace.project_id
      terraform_version = workspace.terraform_version
    }
  } : {}
}

output "domain_name" {
  value     = var.domain_name
  sensitive = true
}
