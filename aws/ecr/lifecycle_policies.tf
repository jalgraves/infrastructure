# +-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |H|Q|O| |D|E|V|O|P|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+ +-+-+ +-+-+-+ +-+-+-+-+

locals {
  lifecycle_policies = {
    keep-last-5               = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep only the latest 5 images",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 5
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
    EOF
    keep-last-250             = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep only the latest 250 tagged images",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 250
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
    EOF
    delete-development-images = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep only the last 5 tagged prefixed development-* images. Maintained via Terraform workspace ${terraform.workspace}.",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["development-"],
            "countType": "imageCountMoreThan",
            "countNumber": 5
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 20,
          "description": "Expire untagged images older than 3 days. Maintained via Terraform workspace ${terraform.workspace}.",
          "selection": {
              "tagStatus": "untagged",
              "countType": "sinceImagePushed",
              "countUnit": "days",
              "countNumber": 3
          },
          "action": {
              "type": "expire"
          }
        }
      ]
    }
    EOF
    development               = <<EOF
    {
        "rules": [
            {
              "rulePriority": 10,
              "description": "Keep latest images",
              "selection": {
                  "tagStatus": "tagged",
                  "tagPrefixList": ["latest"],
                  "countType": "imageCountMoreThan",
                  "countNumber": 9999
              },
              "action": {
                  "type": "expire"
              }
            },
            {
              "rulePriority": 20,
              "description": "Expire untagged images older than 7 days",
              "selection": {
                  "tagStatus": "untagged",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 7
              },
              "action": {
                  "type": "expire"
              }
            },
            {
              "rulePriority": 30,
              "description": "Expire images after 7 days",
              "selection": {
                  "tagStatus": "any",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 7
              },
              "action": {
                  "type": "expire"
              }
            }
        ]
    }
    EOF
    default                   = <<EOF
    {
      "rules": [
        {
          "rulePriority": 10,
          "description": "Keep latest images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["latest"],
            "countType": "imageCountMoreThan",
            "countNumber": 9999
          },
          "action": {
              "type": "expire"
          }
        },
        {
          "rulePriority": 20,
          "description": "Expire untagged images older than 7 days",
          "selection": {
            "tagStatus": "untagged",
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": 7
          },
          "action": {
              "type": "expire"
          }
        },
        {
          "rulePriority": 30,
          "description": "Expire development images older than 7 days",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["development-"],
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": 7
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
    EOF
  }
}
