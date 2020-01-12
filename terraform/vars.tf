variable "aws_region" { default = "us-east-2" }

variable "aws_amis" {
    default = {
        us-east-1 = "ami-00068cd7555f543d5"
        us-east-2 = "ami-0dacb0c129b49f529"
    }
}

variable "buckets" {
    description = "S3 buckets"
    default     = ["terraform-state", "static-assets", "etcd-snapshots", "jke-ingress-alb-logs"]
}

variable "base_cidr_block" {
    description = "A /16 CIDR range definition"
    default = "10.0.0.0/16"
}