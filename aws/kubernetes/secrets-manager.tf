# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

locals {
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

resource "aws_secretsmanager_secret" "database_creds" {
  name                    = "${local.configs.cluster_name}-database-creds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.database_creds.id
  secret_string = jsonencode(local.database_creds)
}
