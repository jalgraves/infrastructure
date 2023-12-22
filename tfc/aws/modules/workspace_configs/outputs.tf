# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# Docs
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace

locals {
  workspaces = {
    admin-aws-iam-identity-provider-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "iam-identity-provider"
      env                   = "admin"
      execution_mode        = "local"
      file_triggers_enabled = true
      queue_all_runs        = false
      region_codes          = []
      speculative_enabled   = true
      trigger_patterns      = ["aws/iam-identity-provider/*.tf"]
      use_tfc               = true
      use_vault             = true
      global_remote_state   = false
    }
    #### DEVELOPMENT WORKSPACES ####
    development-aws-ecr-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "ecr"
      env                   = "development"
      execution_mode        = "remote"
      file_triggers_enabled = true
      queue_all_runs        = true
      region_codes          = ["use1", "use2"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/ecr/*.tf", "aws/ecr/modules/workspace_configs/development-aws-ecr-*.tf", "aws/ecr/modules/workspace_configs/outputs.tf"]
      use_tfc               = false
      global_remote_state   = true
    }

    development-aws-kubernetes-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      env                   = "development"
      directory             = "kubernetes"
      execution_mode        = "local"
      file_triggers_enabled = true
      queue_all_runs        = false
      region_codes          = ["use1", "use2"]
      speculative_enabled   = true
      trigger_patterns = [
        "aws/kubernetes/*.tf",
        "aws/kubernetes/modules/workspace_configs/development-aws-kubernetes-*.tf",
        "aws/kubernetes/modules/iam/*.tf",
        "aws/kubernetes/modules/irsa/*.tf"
      ]
      use_tfc             = true
      global_remote_state = true
    }

    development-aws-vpc-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "vpc"
      env                   = "development"
      execution_mode        = "local"
      file_triggers_enabled = true
      organization          = "jalgraves"
      queue_all_runs        = false
      region_codes          = ["use1", "use2"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/vpc/*.tf", "aws/vpc/modules/workspace_configs/development-aws-vpc-*.tf"]
      use_tfc               = true
      use_vault             = true
      global_remote_state   = true
    }

    development-aws-route53-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "route53"
      env                   = "development"
      execution_mode        = "local"
      file_triggers_enabled = true
      organization          = "jalgraves"
      queue_all_runs        = false
      region_codes          = ["use1", "use2"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/route53/*.tf"]
      use_tfc               = false
      use_vault             = false
      global_remote_state   = true
    }

    #### PRODUCTION WORKSPACES ####
    production-aws-ecr-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "ecr"
      env                   = "production"
      execution_mode        = "remote"
      file_triggers_enabled = true
      organization          = "jalgraves"
      queue_all_runs        = true
      region_codes          = ["use1"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/ecr/*.tf", "aws/ecr/modules/workspace_configs/production-aws-ecr-*.tf", "aws/ecr/modules/workspace_configs/outputs.tf"]
      use_tfc               = false
      global_remote_state   = true
    }
    production-aws-kubernetes-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "kubernetes"
      env                   = "production"
      execution_mode        = "local"
      file_triggers_enabled = true
      organization          = "beantownpub"
      queue_all_runs        = true
      region_codes          = ["use1", "use2"]
      speculative_enabled   = true
      trigger_patterns = [
        "aws/kubernetes/*.tf",
        "aws/kubernetes/modules/workspace_configs/production-aws-kubernetes-*.tf",
        "aws/kubernetes/modules/iam/*.tf",
        "aws/kubernetes/modules/irsa/*.tf"
      ]
      use_tfc             = true
      global_remote_state = true
    }

    production-aws-vpc-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "vpc"
      env                   = "production"
      execution_mode        = "local"
      file_triggers_enabled = true
      organization          = "beantownpub"
      queue_all_runs        = true
      region_codes          = ["use1", "use2"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/vpc/*.tf", "aws/vpc/modules/workspace_configs/production-aws-vpc-*.tf"]
      use_tfc               = true
      global_remote_state   = true
    }

    production-aws-route53-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "route53"
      env                   = "production"
      execution_mode        = "local"
      file_triggers_enabled = true
      organization          = "beantownpub"
      queue_all_runs        = true
      region_codes          = ["use1", "use2"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/route53/*.tf"]
      use_tfc               = true
      global_remote_state   = true
    }
  }
}

variable "workspace" {}

output "values" {
  value = local.workspaces[var.workspace]
}
