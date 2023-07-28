# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "automated_user" {}
variable "control_plane_endpoint" {}
variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}
variable "domain_name" { default = null }
variable "nlb_hostname" { default = null }
variable "tfc_token" {}