# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "cluster_name" {
  type        = string
  description = <<EOT
    The name of the Kubernetes cluster. This is used to name and tag roles and policies.
  EOT
}
variable "env" {
  type        = string
  description = <<EOT
    The name of the environment, e.g "production"
  EOT
}
variable "oidc" {
  type        = object(map(string))
  description = <<EOT
    The OIDC issuer and provider ARN. These values come from the `irsa` module
  EOT
}
variable "region" {
  type        = string
  description = <<EOT
    The name of the AWS region, e.g "us-east-1"
  EOT
}
variable "region_code" {
  type        = string
  description = <<EOT
    The abbreviated code for the AWS region, e.g "use1"
  EOT
}
