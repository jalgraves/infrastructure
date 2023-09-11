# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  secrets = [
    {
      name        = "app-creds"
      description = "Credentials and secrets shared by several applications. Created via Terraform workspace ${terraform.workspace}"
      secrets = {
        api_user = var.api_user
        api_pass = var.api_pass
        db_host  = var.db_host
        db_pass  = var.db_pass
        db_port  = var.db_port
        db_user  = var.db_user
      }
    },
    {
      name        = "beantown-creds"
      description = "Credentials and secrets for beantown frontend. Created via Terraform workspace ${terraform.workspace}"
      secrets = {
        api_user                      = var.api_user
        api_pass                      = var.api_pass
        kafka_bootstrap_server        = var.kafka_bootstrap_server
        kafka_password                = var.kafka_password
        kafka_username                = var.kafka_username
        session_secret                = var.session_secret
        square_access_token_dev       = var.square_access_token_dev
        square_access_token_prod      = var.square_access_token_prod
        square_application_id_sandbox = var.square_application_id_sandbox
        square_location_id            = var.square_location_id
        square_url                    = var.square_url
        merch_api_host                = var.merch_api_host
        merch_api_port                = var.merch_api_port
        menu_api_host                 = var.menu_api_host
        menu_api_port                 = var.menu_api_port
        contact_api_host              = var.contact_api_host
        contact_api_port              = var.contact_api_port
        users_api_host                = var.users_api_host
        users_api_port                = var.users_api_port
      }
    },
    {
      name        = "thehubpub-creds"
      description = "Credentials and secrets for beantown frontend. Created via Terraform workspace ${terraform.workspace}"
      secrets = {
        api_user         = var.api_user
        api_pass         = var.api_pass
        merch_api_host   = var.merch_api_host
        merch_api_port   = var.merch_api_port
        menu_api_host    = var.menu_api_host
        menu_api_port    = var.menu_api_port
        contact_api_host = var.contact_api_host
        contact_api_port = var.contact_api_port
        users_api_host   = var.users_api_host
        users_api_port   = var.users_api_port
      }
    },
    {
      name        = "contact-api-creds"
      description = "Secrets for contact-api. Created via Terraform workspace ${terraform.workspace}"
      secrets = {
        api_username             = var.api_user
        api_password             = var.api_pass
        db_name                  = var.contact_api_db_name
        db_host                  = var.db_host
        db_pass                  = var.db_pass
        db_port                  = var.db_port
        db_user                  = var.db_user
        email_recipient          = var.email_recipient
        second_email_recipient   = var.second_email_recipient
        slack_orders_channel     = var.slack_orders_channel
        slack_orders_webhook_url = var.slack_orders_webhook_url
        slack_partys_channel     = var.slack_partys_channel
        slack_partys_webhook_url = var.slack_partys_webhook_url
        slack_user               = var.slack_user
        slack_webhook_url        = var.slack_webhook_url
        support_email_address    = var.support_email_address
        support_phone_number     = var.support_phone_number
        test_email_recipient     = var.test_email_recipient
      }
    },
    {
      name        = "database-creds"
      description = "Database credentials for Postgresql DB. Created via Terraform workspace ${terraform.workspace}"
      secrets = {
        contact_db_name = var.contact_api_db_name
        db_admin_pass   = var.db_admin_pass
        db_admin_user   = var.db_admin_user
        db_user         = var.db_user
        db_pass         = var.db_pass
        menu_db_name    = var.menu_api_db_name
        merch_db_name   = var.merch_api_db_name
        users_db_name   = var.users_api_db_name
      }
    },
    {
      name        = "menu-api-creds"
      description = "Secrets for menu-api. Created via Terraform workspace ${terraform.workspace}"
      secrets = {
        db_name      = var.menu_api_db_name
        api_username = var.api_user
        api_password = var.api_pass
        db_host      = var.db_host
        db_pass      = var.db_pass
        db_port      = var.db_port
        db_user      = var.db_user
      }
    }
  ]
}

# SECRETS
resource "aws_secretsmanager_secret" "secrets" {
  for_each = {
    for secret in local.secrets : secret.name => secret
  }
  description             = each.value.description
  name                    = "${local.configs.cluster_name}-${each.value.name}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "values" {
  for_each = {
    for secret in local.secrets : secret.name => secret
  }
  secret_id     = aws_secretsmanager_secret.secrets[each.value.name].id
  secret_string = jsonencode(each.value.secrets)
}
