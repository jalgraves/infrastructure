# AWS VPC

Permissions needed to manage VPC resources:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Terraform",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeImages",
                "ec2:DescribeAvailabilityZones",
                "ec2:CreateTags",
                "ec2:CreateVpc",
                "ec2:DescribeVpcs",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeEgressOnlyInternetGateways",
                "ec2:DescribeSubnets",
                "ec2:DescribeRouteTables",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DescribeInstanceCreditSpecifications"
            ],
            "Resource": "*"
        },
        {
            "Sid": "TerraformVPC",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcAttribute",
                "ec2:DeleteVpc",
                "ec2:ModifyVpcAttribute",
                "ec2:CreateSubnet",
                "ec2:CreateEgressOnlyInternetGateway",
                "ec2:CreateRouteTable",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSubnet",
                "ec2:AttachInternetGateway",
                "ec2:CreateRoute",
                "ec2:ModifySubnetAttribute",
                "ec2:CreateNetworkAcl",
                "ec2:AssociateRouteTable",
                "ec2:DeleteNetworkAcl",
                "ec2:ReplaceNetworkAclAssociation",
                "ec2:CreateNetworkAclEntry",
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RunInstances",
                "ec2:DescribeInstanceAttribute",
                "ec2:TerminateInstances",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DisassociateRouteTable",
                "ec2:DisassociateSubnetCidrBlock",
                "ec2:DeleteTags",
                "ec2:DeleteNetworkAclEntry",
                "ec2:DeleteRoute",
                "ec2:DetachInternetGateway"
            ],
            "Resource": [
                "arn:aws:ec2:us-east-1:<account_id>:vpc/*",
                "arn:aws:ec2:us-east-1:<account_id>:route-table/*",
                "arn:aws:ec2:us-east-1:<account_id>:subnet/*",
                "arn:aws:ec2:us-east-1:<account_id>:network-acl/*",
                "arn:aws:ec2:us-east-1:<account_id>:security-group/*",
                "arn:aws:ec2:us-east-1:<account_id>:instance/*",
                "arn:aws:ec2:us-east-1:<account_id>:network-interface/*",
                "arn:aws:ec2:us-east-1:<account_id>:volume/*",
                "arn:aws:ec2:us-east-1::image/*"
            ]
        },
        {
            "Sid": "TerraformInternetGateway",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachInternetGateway",
                "ec2:CreateInternetGateway",
                "ec2:CreateEgressOnlyInternetGateway",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteEgressOnlyInternetGateway",
                "ec2:DetachInternetGateway"
            ],
            "Resource": [
                "arn:aws:ec2:us-east-1:<account_id>:internet-gateway/*",
                "arn:aws:ec2:us-east-1:<account_id>:egress-only-internet-gateway/*"
            ]
        }
    ]
}
```
