# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# Docs
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace

module "configs" {
  source = "./modules/workspace_configs"

  workspace = terraform.workspace
}

locals {
  configs           = module.configs.values
  config_path       = "aws/${local.configs.directory}/modules/workspace_configs"
  terraform_version = "1.5.3"
}

resource "tfe_workspace" "this" {
  for_each = {
    for k, v in toset(local.configs.region_codes) : k => v
    if length(local.configs.region_codes) > 0
  }
  auto_apply            = local.configs.auto_apply
  assessments_enabled   = local.configs.assessments_enabled
  name                  = "${local.configs.env}-aws-${local.configs.directory}-${each.value}"
  description           = "Workspace for ${local.configs.env} AWS ${upper(local.configs.directory)} resources. Created via Terraform workspace ${terraform.workspace}"
  organization          = var.organization
  execution_mode        = local.configs.execution_mode
  file_triggers_enabled = local.configs.file_triggers_enabled
  global_remote_state   = local.configs.global_remote_state
  queue_all_runs        = local.configs.queue_all_runs
  speculative_enabled   = local.configs.speculative_enabled
  tag_names             = [local.configs.env, each.value, "aws", local.configs.directory]
  terraform_version     = local.terraform_version
  trigger_patterns      = local.configs.trigger_patterns
  working_directory     = "aws/${local.configs.directory}"
  vcs_repo {
    branch             = local.configs.branch
    identifier         = "${var.organization}/infrastructure"
    ingress_submodules = false
    oauth_token_id     = var.oauth_token_id
  }
}

resource "tfe_notification_configuration" "this" {
  for_each = {
    for k, v in toset(local.configs.region_codes) : k => v
    if length(local.configs.region_codes) > 0
  }
  name             = "${local.configs.env}-aws-${local.configs.directory}-${each.value}-notification-configuration"
  enabled          = true
  destination_type = "slack"
  triggers         = ["run:errored", "run:needs_attention", "run:completed"]
  url              = var.slack_webhook_url
  workspace_id     = tfe_workspace.this[each.value].id
}
