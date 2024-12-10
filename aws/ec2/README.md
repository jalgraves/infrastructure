# AWS EC2

Required permissions:

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
                "ec2:TerminateInstances"
            ],
            "Resource": [
                "arn:aws:ec2:us-east-1:826438047975:vpc/*",
                "arn:aws:ec2:us-east-1:826438047975:route-table/*",
                "arn:aws:ec2:us-east-1:826438047975:subnet/*",
                "arn:aws:ec2:us-east-1:826438047975:network-acl/*",
                "arn:aws:ec2:us-east-1:826438047975:security-group/*",
                "arn:aws:ec2:us-east-1:826438047975:instance/*",
                "arn:aws:ec2:us-east-1:826438047975:network-interface/*",
                "arn:aws:ec2:us-east-1:826438047975:volume/*",
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
                "ec2:DeleteEgressOnlyInternetGateway"
            ],
            "Resource": [
                "arn:aws:ec2:us-east-1:826438047975:internet-gateway/*",
                "arn:aws:ec2:us-east-1:826438047975:egress-only-internet-gateway/*"
            ]
        }
    ]
}
```
