provider "aws" {
  profile = "beantown"
  region  = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "jal-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "jal-terraform-state-lock"
    encrypt        = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    # Enables full revision history of state files
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = var.dynamodb_pay_method
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
