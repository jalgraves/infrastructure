# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
  app_creds = {
    api_user = var.api_user
    api_pass = var.api_pass
    db_host  = var.db_host
    db_pass  = var.db_pass
    db_port  = var.db_port
    db_user  = var.db_user
  }
  beantown_creds = {
    kafka_bootstrap_server        = var.kafka_bootstrap_server
    kafka_password                = var.kafka_password
    kafka_username                = var.kafka_username
    session_secret                = var.session_secret
    square_access_token_dev       = var.square_access_token_dev
    square_access_token_prod      = var.square_access_token_prod
    square_application_id_sandbox = var.square_application_id_sandbox
    square_url                    = var.square_url
  }
  contact_api_creds = {
    aws_access_key_id        = aws_iam_access_key.ses_sender.id
    aws_default_region       = local.configs.region
    aws_secret_access_key    = aws_iam_access_key.ses_sender.secret
    email_recipient          = var.email_recipient
    second_email_recipient   = var.second_email_recipient
    slack_channel            = var.slack_channel
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
  database_creds = {
    contact_db_name = var.contact_db_name
    db_admin_pass   = var.db_admin_pass
    db_admin_user   = var.db_admin_user
    db_user         = var.db_user
    db_pass         = var.db_pass
    menu_db_name    = var.menu_db_name
    merch_db_name   = var.merch_db_name
    users_db_name   = var.users_db_name
  }
}

resource "aws_secretsmanager_secret" "app_creds" {
  name                    = "${local.configs.cluster_name}-app-creds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "beantown_creds" {
  name                    = "${local.configs.cluster_name}-database-creds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "database_creds" {
  name                    = "${local.configs.cluster_name}-database-creds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app_creds" {
  secret_id     = aws_secretsmanager_secret.database_creds.id
  secret_string = jsonencode(local.database_creds)
}

resource "aws_secretsmanager_secret_version" "beantown_creds" {
  secret_id     = aws_secretsmanager_secret.beantown_creds.id
  secret_string = jsonencode(local.beantown_creds)
}

resource "aws_secretsmanager_secret" "contact_api_creds" {
  name                    = "${local.configs.cluster_name}-contact-api-creds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "contact_api_creds" {
  secret_id     = aws_secretsmanager_secret.contact_api_creds.id
  secret_string = jsonencode(local.contact_api_creds)
}
