# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "automated_user" {}
variable "api_port" {}
variable "control_plane_endpoint" {}
variable "cluster_domain" { default = null }
variable "gateway_domains" { default = [] }
variable "oidc_jwks" {
  default = null
}
variable "org" {}
variable "tfc_token" {}
variable "sa_signer_key" {}
variable "sa_signer_pkcs8_pub" {}
#variable "sha1_fingerprint" {}
