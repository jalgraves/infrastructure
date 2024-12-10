# AWS IAM

Workspaces for creating IAM resources

Resources created here can be used in other workspaces.

IAM Permissions that need to be in place for Terraform to manage resources:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformIAM",
            "Effect": "Allow",
            "Action": [
                "iam:TagRole",
                "iam:CreateRole",
                "iam:GetRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:TagInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:CreatePolicy",
                "iam:TagPolicy",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicyVersions",
                "iam:DeletePolicy"
            ],
            "Resource": "*"
        },
        {
            "Sid": "TerraformIAMPassRole",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::826438047975:role/DevelopmentUse1*"
        }
    ]
}
```
