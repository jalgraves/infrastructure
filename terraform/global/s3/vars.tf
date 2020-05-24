variable "aws_region" { default = "us-east-2" }

variable "state_bucket_name" { default = "jal-terraform-state" }

variable "dynamodb_table_name" { default = "jal-terraform-state-lock" }

variable "dynamodb_pay_method" { default = "PAY_PER_REQUEST" }