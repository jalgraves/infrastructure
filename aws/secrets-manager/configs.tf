module "configs" {
  source = "./modules/workspace_configs"

  workspace                 = terraform.workspace
  API_USERNAME              = var.API_USERNAME
  API_PASSWORD              = var.API_PASSWORD
  DATABASE_HOST             = var.DATABASE_HOST
  DB_ADMIN_PASS             = var.DB_ADMIN_PASS
  DB_ADMIN_USER             = var.DB_ADMIN_USER
  DB_PASS                   = var.DB_PASS
  DB_USER                   = var.DB_USER
  DB_PORT                   = var.DB_PORT
  CONTACT_DB_NAME           = var.CONTACT_DB_NAME
  CONTENT_DB_NAME           = var.CONTENT_DB_NAME
  MENU_DB_NAME              = var.MENU_DB_NAME
  MERCH_DB_NAME             = var.MERCH_DB_NAME
  USERS_DB_NAME             = var.USERS_DB_NAME
  AWS_DEFAULT_REGION        = var.AWS_DEFAULT_REGION
  PRIMARY_EMAIL_RECIPIENT   = var.PRIMARY_EMAIL_RECIPIENT
  SECONDARY_EMAIL_RECIPIENT = var.SECONDARY_EMAIL_RECIPIENT
  SLACK_ORDERS_CHANNEL      = var.SLACK_ORDERS_CHANNEL
  SLACK_ORDERS_WEBHOOK_URL  = var.SLACK_ORDERS_WEBHOOK_URL
  SLACK_PARTYS_CHANNEL      = var.SLACK_PARTYS_CHANNEL
  SLACK_PARTYS_WEBHOOK_URL  = var.SLACK_PARTYS_WEBHOOK_URL
  SLACK_USER                = var.SLACK_USER
  SLACK_WEBHOOK_URL         = var.SLACK_WEBHOOK_URL
  SUPPORT_EMAIL_ADDRESS     = var.SUPPORT_EMAIL_ADDRESS
  SUPPORT_PHONE_NUMBER      = var.SUPPORT_PHONE_NUMBER
  TEST_EMAIL_RECIPIENT      = var.TEST_EMAIL_RECIPIENT
  LOG_LEVEL                 = var.LOG_LEVEL
  CONTACT_API_HOST          = var.CONTACT_API_HOST
  CONTACT_API_PROTOCOL      = var.CONTACT_API_PROTOCOL
  CONTACT_API_PORT          = var.CONTACT_API_PORT
  MENU_API_HOST             = var.MENU_API_HOST
  MENU_API_PROTOCOL         = var.MENU_API_PROTOCOL
  MENU_API_PORT             = var.MENU_API_PORT
  NODE_ENV                  = var.NODE_ENV
}

locals {
  configs = module.configs.values
}
