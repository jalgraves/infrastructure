# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_iam_role" "k8s_control_plane" {
  name = "${title(var.env)}${title(var.region_code)}K8sControlPlane"
  path = "/"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    "Name" = "${title(var.env)}${title(var.region_code)}K8sControlPlane"
  }
}

resource "aws_iam_instance_profile" "k8s_control_plane" {
  name = "${title(var.env)}${title(var.region_code)}K8sControlPlane"
  role = aws_iam_role.k8s_control_plane.name
}

resource "aws_iam_policy" "k8s_control_plane" {
  name        = "${title(var.env)}${title(var.region_code)}K8sControlPlanePolicy"
  path        = "/"
  description = "Policy for K8s control plane nodes. Created via Terraform workspace ${terraform.workspace}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
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
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Sid" : "SSMGet",
        "Effect" : "Allow",
        "Action" : "ssm:GetParameter",
        "Resource" : [
          "arn:aws:ssm:*:*:parameter/aws/service/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "k8s_control_plane" {
  role       = aws_iam_role.k8s_control_plane.name
  policy_arn = aws_iam_policy.k8s_control_plane.arn
}

resource "aws_iam_role_policy_attachment" "k8s_control_plane_test" {
  role       = aws_iam_role.k8s_control_plane.name
  policy_arn = aws_iam_policy.k8s_worker.arn
}
