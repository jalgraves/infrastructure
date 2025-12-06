# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+

data "aws_caller_identity" "current" {}
data "aws_secretsmanager_secret_version" "psql" {
  secret_id = "psql"
}

data "aws_secretsmanager_secret_version" "menu-api" {
  secret_id = "menu-api"
}

data "aws_secretsmanager_secret_version" "contact-api" {
  secret_id = "contact-api"
}

data "aws_secretsmanager_secret_version" "beantownpub" {
  secret_id = "beantownpub"
}

module "configs" {
  source = "./modules/workspace_configs"

  workspace = terraform.workspace
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  configs    = module.configs.values
  services = {
    menu-api = {
      port               = 5004,
      public             = true
      image              = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/menu-api:0.1.20"
      healthcheck        = "/v1/menu/healthz"
      certificate_domain = "beantownpub.com"
      desired_count      = 2
      secrets = [
        {
          name      = "LOG_LEVEL"
          valueFrom = "${data.aws_secretsmanager_secret_version.menu-api.arn}:LOG_LEVEL::"
        },
        {
          name      = "DATABASE_HOST"
          valueFrom = "${data.aws_secretsmanager_secret_version.menu-api.arn}:DATABASE_HOST::"
        },
        {
          name      = "DATABASE_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.menu-api.arn}:DATABASE_USERNAME::"
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret_version.menu-api.arn}:DATABASE_PASSWORD::"
        },
        {
          name      = "DATABASE_PORT"
          valueFrom = "${data.aws_secretsmanager_secret_version.menu-api.arn}:DATABASE_PORT::"
        },
        {
          name      = "DATABASE_NAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.menu-api.arn}:DATABASE_NAME::"
        },
        {
          name      = "API_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.menu-api.arn}:API_USERNAME::"
        },
        {
          name      = "API_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret_version.menu-api.arn}:API_PASSWORD::"
        }
      ]
    }
    contact-api = {
      port               = 5012,
      public             = true
      image              = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/contact-api:0.1.22"
      healthcheck        = "/v1/contact/healthz"
      certificate_domain = "beantownpub.com"
      desired_count      = 1
      secrets = [
        {
          name      = "AWS_DEFAULT_REGION"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:AWS_DEFAULT_REGION::"
        },
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:AWS_ACCESS_KEY_ID::"
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:AWS_SECRET_ACCESS_KEY::"
        },
        {
          name      = "API_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:API_PASSWORD::"
        },
        {
          name      = "API_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:API_USERNAME::"
        },
        {
          name      = "LOG_LEVEL"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:LOG_LEVEL::"
        },
        {
          name      = "PRIMARY_EMAIL_RECIPIENT"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:PRIMARY_EMAIL_RECIPIENT::"
        },
        {
          name      = "SECONDARY_EMAIL_RECIPIENT"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:SECONDARY_EMAIL_RECIPIENT::"
        },
        {
          name      = "SLACK_USER"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:SLACK_USER::"
        },
        {
          name      = "SLACK_WEBHOOK_URL"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:SLACK_WEBHOOK_URL::"
        },
        {
          name      = "SUPPORT_EMAIL_ADDRESS"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:SUPPORT_EMAIL_ADDRESS::"
        },
        {
          name      = "SUPPORT_PHONE_NUMBER"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:SUPPORT_PHONE_NUMBER::"
        },
        {
          name      = "TEST_EMAIL_RECIPIENT"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:TEST_EMAIL_RECIPIENT::"
        },
        {
          name      = "SLACK_ORDERS_CHANNEL"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:SLACK_ORDERS_CHANNEL::"
        },
        {
          name      = "SLACK_ORDERS_WEBHOOK_URL"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:SLACK_ORDERS_WEBHOOK_URL::"
        },
        {
          name      = "SLACK_PARTYS_CHANNEL"
          valueFrom = "${data.aws_secretsmanager_secret_version.contact-api.arn}:SLACK_PARTYS_CHANNEL::"
        }
      ]
    }
    beantownpub = {
      port               = 3000,
      public             = true
      image              = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/beantownpub:0.1.67"
      healthcheck        = "/"
      certificate_domain = "beantownpub.com"
      desired_count      = 2
      secrets = [
        {
          name      = "API_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:API_PASSWORD::"
        },
        {
          name      = "API_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:API_USERNAME::"
        },
        {
          name      = "CONTACT_API_HOST"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:CONTACT_API_HOST::"
        },
        {
          name      = "CONTACT_API_PROTOCOL"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:CONTACT_API_PROTOCOL::"
        },
        {
          name      = "CONTACT_API_PORT"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:CONTACT_API_PORT::"
        },
        {
          name      = "MENU_API_HOST"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:MENU_API_HOST::"
        },
        {
          name      = "MENU_API_PROTOCOL"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:MENU_API_PROTOCOL::"
        },
        {
          name      = "MENU_API_PORT"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:MENU_API_PORT::"
        },
        {
          name      = "NODE_ENV"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:NODE_ENV::"
        }
      ]
    }
    thehubpub = {
      port               = 3037,
      public             = true
      image              = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/thehubpub:0.1.20"
      healthcheck        = "/"
      certificate_domain = "thehubpub.com"
      desired_count      = 1
      secrets = [
        {
          name      = "API_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:API_PASSWORD::"
        },
        {
          name      = "API_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:API_USERNAME::"
        },
        {
          name      = "CONTACT_API_HOST"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:CONTACT_API_HOST::"
        },
        {
          name      = "CONTACT_API_PROTOCOL"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:CONTACT_API_PROTOCOL::"
        },
        {
          name      = "CONTACT_API_PORT"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:CONTACT_API_PORT::"
        },
        {
          name      = "MENU_API_HOST"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:MENU_API_HOST::"
        },
        {
          name      = "MENU_API_PROTOCOL"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:MENU_API_PROTOCOL::"
        },
        {
          name      = "MENU_API_PORT"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:MENU_API_PORT::"
        },
        {
          name      = "NODE_ENV"
          valueFrom = "${data.aws_secretsmanager_secret_version.beantownpub.arn}:NODE_ENV::"
        }
      ]
    }
    wavelengths = {
      port               = 8080,
      public             = true
      image              = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/wavelengths"
      healthcheck        = "/"
      certificate_domain = "wavelengths-brookline.com"
      desired_count      = 1
    }
    drdavisicecream = {
      port               = 3034,
      public             = true
      image              = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/drdavisicecream:0.1.27-9b4ad10"
      healthcheck        = "/"
      certificate_domain = "drdavisicecream.com"
      desired_count      = 1
    }
    psql = {
      port               = 5432,
      public             = false
      image              = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/psql:latest"
      healthcheck        = null
      certificate_domain = null
      desired_count      = 1
      secrets = [
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:POSTGRES_PASSWORD::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:DB_PASS::"
        },
        {
          name      = "DB_ADMIN_PASS"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:DB_ADMIN_PASS::"
        },
        {
          name      = "DB_ADMIN_USER"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:DB_ADMIN_USER::"
        },
        {
          name      = "DB_PASS"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:DB_PASS::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:DB_USER::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:DB_PORT::"
        },
        {
          name      = "CONTACT_DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:CONTACT_DB_NAME::"
        },
        {
          name      = "CONTENT_DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:CONTENT_DB_NAME::"
        },
        {
          name      = "MENU_DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:MENU_DB_NAME::"
        },
        {
          name      = "MERCH_DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:MERCH_DB_NAME::"
        },
        {
          name      = "USERS_DB_NAME"
          valueFrom = "${data.aws_secretsmanager_secret_version.psql.arn}:USERS_DB_NAME::"
        }
      ]
    }
  }
}
