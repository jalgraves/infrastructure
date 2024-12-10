# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

variable "workspace" {
  type        = string
  description = <<EOT
    The Terraform workspace that is selected before Terraform runs.
    It is used to determine which values to use when creating the resources in the root `eks/` directory.
  EOT
}
