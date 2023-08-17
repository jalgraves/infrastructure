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
