# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# Docs
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace

locals {
  workspaces = {

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
      region_codes          = ["use1"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/ecr/*.tf", "aws/ecr/modules/workspace_configs/development-aws-ecr-*.tf", "aws/ecr/modules/workspace_configs/outputs.tf"]
      use_tfc               = false
      use_vault             = false
      global_remote_state   = true
    }

    development-aws-kubernetes-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      env                   = "development"
      directory             = "kubernetes"
      execution_mode        = "remote"
      file_triggers_enabled = true
      queue_all_runs        = false
      region_codes          = ["use1"]
      speculative_enabled   = true
      trigger_patterns = [
        "aws/kubernetes/*.tf",
        "aws/kubernetes/modules/workspace_configs/development-aws-kubernetes-*.tf",
        "aws/kubernetes/modules/rbac/*.tf",
        "aws/kubernetes/modules/helm/*.tf",
        "aws/kubernetes/lambda_functions/*.tpl"
      ]
      use_tfc             = true
      use_vault           = true
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
      region_codes          = ["use1"]
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
      execution_mode        = "remote"
      file_triggers_enabled = true
      organization          = "jalgraves"
      queue_all_runs        = false
      region_codes          = ["use1"]
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
      use_vault             = false
      global_remote_state   = true
    }
    production-aws-kubernetes-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "kubernetes"
      env                   = "production"
      execution_mode        = "remote"
      file_triggers_enabled = true
      organization          = "jalgraves"
      queue_all_runs        = true
      region_codes          = ["use1"]
      speculative_enabled   = true
      trigger_patterns = [
        "aws/kubernetes/*.tf",
        "aws/kubernetes/modules/workspace_configs/production-aws-kubernetes-*.tf",
        "aws/kubernetes/modules/rbac/*.tf",
        "aws/kubernetes/modules/helm/*.tf",
        "aws/kubernetes/lambda_functions/*.tpl"
      ]
      use_tfc             = true
      use_vault           = true
      global_remote_state = true
    }

    production-aws-vpc-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "vpc"
      env                   = "production"
      execution_mode        = "remote"
      file_triggers_enabled = true
      organization          = "jalgraves"
      queue_all_runs        = true
      region_codes          = ["use1"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/vpc/*.tf", "aws/vpc/modules/workspace_configs/production-aws-vpc-*.tf"]
      use_tfc               = true
      use_vault             = true
      global_remote_state   = true
    }

    production-aws-route53-tfc = {
      assessments_enabled   = true
      auto_apply            = true
      branch                = "master"
      directory             = "route53"
      env                   = "production"
      execution_mode        = "remote"
      file_triggers_enabled = true
      organization          = "jalgraves"
      queue_all_runs        = true
      region_codes          = ["euc1"]
      speculative_enabled   = true
      trigger_patterns      = ["aws/route53/*.tf"]
      use_tfc               = false
      use_vault             = false
      global_remote_state   = true
    }
  }
}

variable "workspace" {}

output "values" {
  value = local.workspaces[var.workspace]
}
