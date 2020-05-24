variable "aws_region" { default = "us-east-2" }

variable "base_cidr_block" {
  description = "A /16 CIDR range definition"
  default     = "10.0.0.0/16"
}
