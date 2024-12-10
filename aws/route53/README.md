# AWS Route53 & ACM

Workspace for creating AWS DNS and certificate resources


IAM permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformRoute53",
            "Effect": "Allow",
            "Action": [
                "route53:CreateHostedZone",
                "route53:GetHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:DeleteHostedZone",
                "route53:ListTagsForResource",
                "route53:GetChange",
                "route53:ChangeTagsForResource",
                "route53:UpdateHostedZoneComment",
                "route53:ListResourceRecordSets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "TerraformACM",
            "Effect": "Allow",
            "Action": [
                "acm:RequestCertificate",
                "acm:AddTagsToCertificate",
                "acm:DescribeCertificate",
                "acm:ListTagsForCertificate",
                "acm:DeleteCertificate"
            ],
            "Resource": "*"
        }
    ]
}
```
