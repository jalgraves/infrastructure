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

resource "aws_secretsmanager_secret_version" "database" {
  secret_id     = aws_secretsmanager_secret.database_creds.id
  secret_string = jsonencode(local.beantown_creds)
}
