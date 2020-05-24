variable "aws_region" { default = "us-east-2" }

variable "environment" {
  description = "The name of the environment."
  default     = "prod"
}

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
  default     = "10.0.0.0/16"
}

variable "worker_nodes" {
  description = "A list of K8s worker nodes"
  default     = ["jke-worker01", "jke-worker02"]
}

variable "worker_instance_type" {
  description = "ec2 instance type for K8s worker nodes"
  default     = "t3.large"
}

variable "node_azs" {
  description = "Availability zones for K8s Nodes"
  default = {
    "rancher01": "us-east-2a",
    "jke-control01": "us-east-2b",
    "jke-worker01": "us-east-2b",
    "jke-worker02": "us-east-2b"
  }
}


variable "worker_azs" {
  description = "Availability zones for K8s workers"
  default = {"jke-worker01": "us-east-2b", "jke-worker02": "us-east-2c"}
}

variable "jke_subnets" {
  description = "Subnets"
  default     = {"jke-worker01": "jalnet_private_2b", "jke-worker02": "jalnet_private_2c"}
}