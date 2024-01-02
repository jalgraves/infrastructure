# IAM

---

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.k8s_control_plane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.k8s_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.k8s_control_plane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.k8s_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.k8s_worker_route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secretsmanager_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ses_send](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.app_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.k8s_control_plane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.k8s_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.app_roles_secretsmanager_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.contact_api_ses_send](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.k8s_control_plane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.k8s_control_plane_test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.k8s_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.k8s_worker_route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.k8s_worker_route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Kubernetes cluster. This is used to name and tag roles and policies. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | The name of the environment, e.g "production" | `string` | n/a | yes |
| <a name="input_oidc"></a> [oidc](#input\_oidc) | The OIDC issuer and provider ARN. These values come from the `irsa` module | `object(map(string))` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The name of the AWS region, e.g "us-east-1" | `string` | n/a | yes |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | The abbreviated code for the AWS region, e.g "use1" | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_role_arns"></a> [app\_role\_arns](#output\_app\_role\_arns) | ARNs for IRSA roles used by running applications in Kubernetes cluster. |
| <a name="output_k8s_control_plane"></a> [k8s\_control\_plane](#output\_k8s\_control\_plane) | The instance profile, role, and policy used by Kubernetes control plane. |
| <a name="output_k8s_worker"></a> [k8s\_worker](#output\_k8s\_worker) | The instance profile, role, and policy used by Kubernetes worker nodes. |
<!-- END_TF_DOCS -->
