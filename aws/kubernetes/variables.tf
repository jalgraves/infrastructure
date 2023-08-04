# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "automated_user" {}
variable "control_plane_endpoint" {}
variable "cluster_domain" { default = null }
# variable "nlb_hostname" { default = null }
variable "oidc_jwks" {
  default = null
}
variable "tfc_token" {}
variable "sa_signer_key" {}
variable "sa_signer_pkcs8_pub" {}
