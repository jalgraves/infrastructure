# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

# Configs specific to the workspace production-aws-iam-use1

locals {
  production-aws-iam-use1 = {
    automated_users = {
      external-secrets = {
        create_keys                         = true
        customer_managed_policy_attachments = ["ProductionUse1ExternalSecretsPolicy"]
        managed_policy_attachments          = []
        secret = {
          name        = "production/use1/external-secrets"
          description = "Secret with credentials for Kubernetes External Secrets. Managed via Terraform workspace ${terraform.workspace}"
        }
      }
      ses-sender-use1 = {
        create_keys                         = true
        customer_managed_policy_attachments = ["ProductionUse1SesPolicy"]
        managed_policy_attachments          = []
        secret = {
          name        = "production/use1/ses-sender-use1"
          description = "Secret with credentials for sending emails. Managed via Terraform workspace ${terraform.workspace}"
        }
      }
    }
    customer_managed_policies = {
      ProductionUse1K8sControlPlanePolicy = {
        description = "Permissions policy for Kubernetes control plane nodes. Managed via Terraform workspace ${terraform.workspace}"
        path        = "/"
        statements = [
          {
            sid = "K8sControlPlane"
            actions = [
              "autoscaling:DescribeAutoScalingGroups",
              "autoscaling:DescribeLaunchConfigurations",
              "autoscaling:DescribeTags",
              "ec2:AttachVolume",
              "ec2:AuthorizeSecurityGroupIngress",
              "ec2:CreateFleet",
              "ec2:CreateLaunchTemplate",
              "ec2:CreateRoute",
              "ec2:CreateSecurityGroup",
              "ec2:CreateTags",
              "ec2:CreateVolume",
              "ec2:DeleteLaunchTemplate",
              "ec2:DeleteRoute",
              "ec2:DeleteSecurityGroup",
              "ec2:DeleteVolume",
              "ec2:DescribeAvailabilityZones",
              "ec2:DescribeImages",
              "ec2:DescribeInstances",
              "ec2:DescribeInstanceTypeOfferings",
              "ec2:DescribeInstanceTypes",
              "ec2:DescribeLaunchTemplates",
              "ec2:DescribeRegions",
              "ec2:DescribeRouteTables",
              "ec2:DescribeSecurityGroups",
              "ec2:DescribeSpotPriceHistory",
              "ec2:DescribeSubnets",
              "ec2:DescribeVolumes",
              "ec2:DescribeVpcs",
              "ec2:DetachVolume",
              "ec2:ModifyInstanceAttribute",
              "ec2:ModifyVolume",
              "ec2:RevokeSecurityGroupIngress",
              "ec2:RunInstances",
              "ec2:TerminateInstances",
              "elasticloadbalancing:*",
              "elasticloadbalancing:AddListenerCertificates",
              "elasticloadbalancing:AddTags",
              "elasticloadbalancing:CreateListener",
              "elasticloadbalancing:CreateRule",
              "elasticloadbalancing:CreateTargetGroup",
              "elasticloadbalancing:DeleteListener",
              "elasticloadbalancing:DeleteTargetGroup",
              "elasticloadbalancing:DescribeListenerCertificates",
              "elasticloadbalancing:DescribeListeners",
              "elasticloadbalancing:DescribeLoadBalancerPolicies",
              "elasticloadbalancing:DescribeRules",
              "elasticloadbalancing:DescribeTags",
              "elasticloadbalancing:DescribeTargetGroups",
              "elasticloadbalancing:DescribeTargetHealth",
              "elasticloadbalancing:ModifyListener",
              "elasticloadbalancing:ModifyRule",
              "elasticloadbalancing:ModifyTargetGroup",
              "elasticloadbalancing:RegisterTargets",
              "elasticloadbalancing:RemoveListenerCertificates",
              "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
              "elasticloadbalancing:SetWebACL",
              "iam:CreateServiceLinkedRole",
              "iam:DeleteServerCertificate",
              "iam:UploadServerCertificate",
              "kms:DescribeKey",
              "pricing:GetProducts",
              "route53:ChangeResourceRecordSets",
              "route53:ListHostedZones",
              "route53:ListResourceRecordSets",
              "shield:GetSubscriptionState",
              "shield:GetSubscriptionState",
              "waf-regional:GetWebACLForResource",
              "wafv2:GetWebACL",
              "wafv2:GetWebACLForResource",
              "sts:*",
              "secretsmanager:PutSecretValue",
              "secretsmanager:GetSecretValue",
              "secretsmanager:ListSecrets",
              "secretsmanager:DescribeSecret",
              "secretsmanager:CreateSecret",
              "secretsmanager:DeleteSecret",
              "secretsmanager:PutSecretValue",
              "secretsmanager:RestoreSecret",
              "secretsmanager:UpdateSecret"
            ]
            conditions = []
            resources  = ["*"]
            effect     = "Allow"
          },
          {
            sid       = "SSMGet"
            actions   = ["ssm:GetParameter"]
            conditons = []
            resources = ["arn:aws:ssm:*:*:parameter/aws/service/*"]
            effect    = "Allow"
          }
        ]
      }
      ProductionUse1K8sWorkerPolicy = {
        description = "Permissions policy for Kubernetes worker nodes. Managed via Terraform workspace ${terraform.workspace}"
        path        = "/"
        statements = [
          {
            sid = "K8sWorker"
            actions = [
              "ec2:*",
              "elasticloadbalancing:*",
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:GetRepositoryPolicy",
              "ecr:DescribeRepositories",
              "ecr:ListImages",
              "ecr:BatchGetImage",
              "sts:AssumeRole",
              "secretsmanager:GetSecretValue",
              "secretsmanager:ListSecrets",
              "secretsmanager:DescribeSecret",
              "shield:GetSubscriptionState",
              "wafv2:GetWebACLForResource"
            ]
            conditions = []
            resources  = ["*"]
            effect     = "Allow"
          }
        ]
      }
      ProductionUse1ExternalSecretsPolicy = {
        description = "Permissions policy for Kubernetes External Secrets. Managed via Terraform workspace ${terraform.workspace}"
        path        = "/"
        statements = [
          {
            sid = "ExternalSecretsSecretsManager"
            actions = [
              "secretsmanager:GetSecretValue",
              "secretsmanager:ListSecrets",
              "secretsmanager:DescribeSecret"
            ]
            conditions = []
            resources = [
              "arn:aws:secretsmanager:us-east-1:*:secret:production/use1/psql*",
              "arn:aws:secretsmanager:us-east-1:*:secret:production/use1/menu-api*",
              "arn:aws:secretsmanager:us-east-1:*:secret:production/use1/contact-api*",
              "arn:aws:secretsmanager:us-east-1:*:secret:production/use1/ses-sender-use1*",
              "arn:aws:secretsmanager:us-east-1:*:secret:production/use1/beantown*",
              "arn:aws:secretsmanager:us-east-1:*:secret:production/use1/thehubpub*"
            ]
            effect = "Allow"
          }
        ]
      }
      ProductionUse1SesPolicy = {
        description = "Permissions policy for sending email with SES. Managed via Terraform workspace ${terraform.workspace}"
        path        = "/"
        statements = [
          {
            sid = "SesSender"
            actions = [
              "ses:SendRawEmail",
              "ses:SendEmail"
            ]
            conditions = []
            resources = [
              "*"
            ]
            effect = "Allow"
          }
        ]
      }
    }
    environment = "production"
    region      = "us-east-1"
    region_code = "use1"
    roles = {
      ProductionUse1Packer = {
        description             = "Role to allow Packer to build AMIs. Managed via Terraform workspace ${terraform.workspace}"
        create_instance_profile = true
        assume_role = {
          statements = [
            {
              actions    = ["sts:AssumeRole"]
              conditions = []
              principals = {
                identifiers = ["ec2.amazonaws.com"]
                type        = "Service"
              }
            }
          ]
        }
        customer_managed_policy_attachments = []
        managed_policy_attachments = [
          # ARNs of the policies that are managed by AWS to attach to the role
          "arn:aws:iam::aws:policy/AdministratorAccess"
        ]
      }
      ProductionUse1K8sControlPlane = {
        description             = "Role for Kubernetes control plane. Managed via Terraform workspace ${terraform.workspace}"
        create_instance_profile = true
        assume_role = {
          statements = [
            {
              actions    = ["sts:AssumeRole"]
              conditions = []
              principals = {
                identifiers = ["ec2.amazonaws.com"]
                type        = "Service"
              }
            }
          ]
        }
        customer_managed_policy_attachments = [
          "ProductionUse1K8sControlPlanePolicy",
          "ProductionUse1K8sWorkerPolicy"
        ]
        managed_policy_attachments = []
      }
    }
  }
}
