variable "aws_region" { default = "us-east-2" }

variable "aws_amis" {
  default = {
    us-east-1 = "ami-00068cd7555f543d5"
    us-east-2 = "ami-0dacb0c129b49f529"
  }
}

variable "node_azs" {
  description = "Availability zones for K8s Nodes"
  default = {
    "rancher01": "us-east-2a",
    "jke-control01": "us-east-2b",
    "jke-worker01": "us-east-2b",
    "jke-worker02": "us-east-2c"
  }
}