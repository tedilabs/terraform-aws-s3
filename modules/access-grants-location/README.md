# access-grants-location

This module creates following resources.

- `aws_s3control_access_grants_location`
- `aws_iam_role` (optional)
- `aws_iam_role_policy` (optional)
- `aws_iam_role_policy_attachment` (optional)

## Notes

- An S3 Access Grants instance must exist in the same account and region before a location can be registered. When composing with the `access-grants-instance` module, add `depends_on` to enforce the ordering.
- The location and its IAM role are cohesive and share the same lifecycle, so the default IAM role is created in this module. The role policy is the upper bound of every access grant for the location — grants can only narrow it down. Keep `location_scope`, the role policy and grant scopes aligned to the same bucket/prefix.
- The default IAM role follows the AWS recommended policy for locations: the trust policy only allows the `access-grants.s3.amazonaws.com` service principal of the current account (`aws:SourceAccount` and `aws:SourceArn` conditions), and each S3 statement is restricted to credentials vended by the S3 Access Grants instance (`s3:AccessGrantsInstanceArn` condition). `sts:SetContext` is included in the trust policy to support `DIRECTORY_USER` / `DIRECTORY_GROUP` grantees with IAM Identity Center.
- If the objects within the location scope are encrypted with `SSE-KMS`, provide the KMS key ARNs with `default_iam_role.kms_keys`. The corresponding KMS key policies must also allow the role.
- Explicit `Deny` statements in bucket policies, SCPs and VPC endpoint policies always take precedence over the vended credentials. The actual S3 requester is the location IAM role session, not the original caller — review bucket policy principals accordingly.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.60.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3control_access_grants_location.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_grants_location) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_location_scope"></a> [location\_scope](#input\_location\_scope) | (Required) The S3 URI of the location to register. The default S3 URI `s3://` covers all S3 buckets in the current AWS account in the region. Use `s3://<bucket>` for a specific bucket, or `s3://<bucket>/<prefix>` for a specific prefix of the bucket. The S3 data must be in the same region as the S3 Access Grants instance. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) A name of the S3 Access Grants location. The name is only used for the `Name` tag, the default IAM role name and module metadata. | `string` | n/a | yes |
| <a name="input_default_iam_role"></a> [default\_iam\_role](#input\_default\_iam\_role) | (Optional) A configuration for the default IAM role for the S3 Access Grants location. S3 Access Grants assumes this role to vend temporary credentials scoped down to the individual grant. The trust policy only allows the S3 Access Grants service principal of the current account, and the permissions follow the AWS recommended policy scoped to `location_scope`. Use `iam_role` if `default_iam_role.enabled` is `false`. `default_iam_role` as defined below.<br/>    (Optional) `enabled` - Whether to create the default IAM role. Defaults to `true`.<br/>    (Optional) `name` - The name of the default IAM role. Defaults to `s3-access-grants-${var.name}-location`.<br/>    (Optional) `path` - The path of the default IAM role. Defaults to `/`.<br/>    (Optional) `description` - The description of the default IAM role.<br/>    (Optional) `permission` - The maximum level of access which the role allows within the location scope. Access grants for the location can only narrow this down. Valid values are `READ`, `WRITE` and `READWRITE`. Defaults to `READWRITE`.<br/>    (Optional) `kms_keys` - A set of ARNs of AWS KMS keys to allow the role to use for `SSE-KMS` encrypted objects within the location scope. Defaults to `[]`.<br/>    (Optional) `policies` - A list of IAM policy ARNs to attach to the default IAM role. Defaults to `[]`.<br/>    (Optional) `inline_policies` - A Map of inline IAM policies to attach to the default IAM role. (`name` => `policy`).<br/>    (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default IAM role. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string)<br/>    path        = optional(string, "/")<br/>    description = optional(string, "Managed by Terraform.")<br/><br/>    permission = optional(string, "READWRITE")<br/>    kms_keys   = optional(set(string), [])<br/><br/>    policies             = optional(list(string), [])<br/>    inline_policies      = optional(map(string), {})<br/>    permissions_boundary = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | (Optional) The ARN (Amazon Resource Name) of the IAM role that S3 Access Grants assumes to vend temporary credentials for the location. Only required if `default_iam_role.enabled` is `false`. | `string` | `null` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grants location. |
| <a name="output_default_iam_role"></a> [default\_iam\_role](#output\_default\_iam\_role) | The configuration of the default IAM role created for the S3 Access Grants location. |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | The ARN of the IAM role that S3 Access Grants assumes to vend temporary credentials for the location. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the S3 Access Grants location. `default` is assigned to the location of the default S3 URI `s3://`. |
| <a name="output_location_scope"></a> [location\_scope](#output\_location\_scope) | The S3 URI of the registered location. |
| <a name="output_name"></a> [name](#output\_name) | The name of the S3 Access Grants location. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
