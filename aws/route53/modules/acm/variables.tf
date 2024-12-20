# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

variable "domain_name" { type = string }
variable "name" { type = string }
variable "subject_alternative_names" { type = list(string) }
variable "zone_id" { type = string }
variable "ns1_hosted_domain" {
  type    = bool
  default = false
}
variable "ns1_api_key" { type = string }
