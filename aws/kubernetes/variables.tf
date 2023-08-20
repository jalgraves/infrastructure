# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "automated_user" {}
variable "api_port" {}
variable "control_plane_endpoint" {}
variable "cluster_domain" { default = null }
variable "github_ssh_secret" { default = null }
variable "gateway_domains" { default = [] }
variable "oidc_jwks" {
  default = null
}
variable "org" {}
variable "tfc_token" {}
variable "sa_signer_key" {}
variable "sa_signer_pkcs8_pub" {}
variable "db_user" {}
variable "db_pass" {}
variable "db_admin_user" {}
variable "db_admin_pass" {}
variable "contact_db_name" {}
variable "menu_db_name" {}
variable "merch_db_name" {}
variable "ssh_public_key" {}
variable "users_db_name" {}

variable "kafka_bootstrap_server" {}
variable "kafka_password" {}
variable "kafka_username" {}
variable "session_secret" {}
variable "square_access_token_dev" {}
variable "square_access_token_prod" {}
variable "square_application_id_sandbox" {}
variable "square_url" {}

variable "api_user" {}
variable "api_pass" {}
variable "db_host" {}
variable "db_port" {}

variable "email_recipient" {}
variable "second_email_recipient" {}
variable "slack_channel" {}
variable "slack_orders_channel" {}
variable "slack_orders_webhook_url" {}
variable "slack_partys_channel" {}
variable "slack_partys_webhook_url" {}
variable "slack_user" {}
variable "slack_webhook_url" {}
variable "support_email_address" {}
variable "support_phone_number" {}
variable "test_email_recipient" {}
