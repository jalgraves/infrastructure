# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "oidc_ca_sha1" {
  default = null
}
variable "oidc_jwks" {
  default = null
}
variable "org" {}
# variable "sha1_fingerprint" {}
