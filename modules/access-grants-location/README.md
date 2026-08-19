# access-grants-location

This module creates following resources.

- `aws_s3control_access_grants_location`
- `aws_iam_role` (optional)
- `aws_iam_role_policy` (optional)
- `aws_iam_role_policy_attachment` (optional)

## Notes

- The S3 Access Grants location must be in the same region with the S3 Access Grants instance and the S3 data.
- The permissions of the location IAM role are the **ceiling** of all grants of the location. A grant can only narrow down the permissions of the location IAM role, and can't extend them. Align the location scope, the permissions of the location IAM role and the scope of each grant.
- The default IAM role of this module is scoped down to `location_scope`, the account of the S3 Access Grants instance (`aws:ResourceAccount`) and the S3 Access Grants instance (`s3:AccessGrantsInstanceArn`). The role can't be used to access the S3 data without the credentials vended by S3 Access Grants.
  - The bucket-level permissions are restricted with the `s3:prefix` condition if the location scope contains a prefix. Listing the objects out of the prefix is denied.
  - Set `default_iam_role.permission` to `READ` to make the location read-only regardless of the permission of each grant.
  - Add `default_iam_role.kms_keys` for the `SSE-KMS` encrypted data. The key policy of each AWS KMS key must also allow the location IAM role.
  - Use `default_iam_role.inline_policies` to add the permissions which are not covered by the generated policy. (e.g. an explicit deny for the non-TLS requests, an explicit deny out of a VPC endpoint)
- Provide `iam_role` with `default_iam_role.enabled` as `false` to bring your own IAM role. The trust policy of the IAM role must allow the `access-grants.s3.amazonaws.com` service principal to call `sts:AssumeRole`, `sts:SetSourceIdentity` and `sts:SetContext`. `sts:SetContext` is required to vend credentials for the IAM Identity Center directory users and groups.
- S3 Access Grants vends the credentials which live up to `default_iam_role.max_session_duration`. Increase the duration to vend credentials which live longer than 1 hour.
- The real requester of the S3 API is the session of the location IAM role, not the original user. Review the bucket policies which allow or deny a specific principal. An explicit deny of the bucket policy always wins over the grant.
- `location_scope` forces a new S3 Access Grants location to be created when changed, because S3 Access Grants only supports to update the IAM role of a registered location.

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
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3control_access_grants_location.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_grants_location) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_instance"></a> [instance](#input\_instance) | (Required) The ARN of the S3 Access Grants instance to register this location in. The S3 Access Grants instance must be in the same region with the location. Used to restrict the trust policy and the permission policy of the default IAM role to the S3 Access Grants instance. | `string` | n/a | yes |
| <a name="input_location_scope"></a> [location\_scope](#input\_location\_scope) | (Required) The S3 URI path of the location to register. The location scope can be the default S3 location `s3://`, the S3 path to a bucket `s3://amzn-s3-demo-bucket/`, or the S3 path to a bucket and prefix `s3://amzn-s3-demo-bucket/prefix/`. The default location `s3://` includes all buckets in the region of the account. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the S3 Access Grants location. S3 Access Grants doesn't support to name the location, so this name is only used to name the module resources like the IAM role, the resource tags and the Resource Group. | `string` | n/a | yes |
| <a name="input_default_iam_role"></a> [default\_iam\_role](#input\_default\_iam\_role) | (Optional) A configurations of the default IAM Role which S3 Access Grants assumes to vend temporary credentials for this location. Use `iam_role` if `default_iam_role.enabled` is `false`. The permissions of the default IAM Role are the ceiling of all grants of this location, and are automatically scoped down to the `location_scope`. `default_iam_role` as defined below.<br/>    (Optional) `enabled` - Whether to create the default IAM Role. Defaults to `true`.<br/>    (Optional) `name` - The name of the default IAM Role. Defaults to `s3-access-grants-${var.name}`.<br/>    (Optional) `path` - The path of the default IAM Role. Defaults to `/`.<br/>    (Optional) `description` - The description of the default IAM Role.<br/>    (Optional) `max_session_duration` - The maximum session duration (in seconds) of the default IAM Role. S3 Access Grants can't vend credentials which live longer than this duration. Valid value is from 1 hour (`3600`) to 12 hours (`43200`). Defaults to `3600`.<br/>    (Optional) `permission` - The maximum level of access to the S3 data of this location. Grants of this location can only narrow down this permission. Valid values are `READ`, `WRITE` and `READWRITE`. Defaults to `READWRITE`.<br/>    (Optional) `object_acl_enabled` - Whether to add the permissions for the S3 object ACL (Access Control List) to the default IAM Role. Not required if the buckets of this location disable ACLs with the `BucketOwnerEnforced` object ownership. Defaults to `false`.<br/>    (Optional) `kms_keys` - A set of ARNs of the AWS KMS keys which encrypt the S3 data of this location. Required to vend credentials for the `SSE-KMS` encrypted objects. The key policy of each AWS KMS key also need to allow the default IAM Role. Defaults to `[]`.<br/>    (Optional) `policies` - A set of IAM policy ARNs to attach to the default IAM Role. Defaults to `[]`.<br/>    (Optional) `inline_policies` - A map of inline IAM policies to attach to the default IAM Role. (`name` => `policy`). Use this to add the permissions which are not covered by the generated policy like the explicit denies for the non-TLS requests.<br/>    (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default IAM Role. | <pre>object({<br/>    enabled              = optional(bool, true)<br/>    name                 = optional(string)<br/>    path                 = optional(string, "/")<br/>    description          = optional(string, "Managed by Terraform.")<br/>    max_session_duration = optional(number, 3600)<br/><br/>    permission         = optional(string, "READWRITE")<br/>    object_acl_enabled = optional(bool, false)<br/>    kms_keys           = optional(set(string), [])<br/><br/>    policies             = optional(set(string), [])<br/>    inline_policies      = optional(map(string), {})<br/>    permissions_boundary = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | (Optional) The ARN of the IAM Role which S3 Access Grants assumes to vend temporary credentials for this location. Only required if `default_iam_role.enabled` is `false`. The trust policy of the IAM Role must allow the `access-grants.s3.amazonaws.com` service principal to call `sts:AssumeRole`, `sts:SetSourceIdentity` and `sts:SetContext`. | `string` | `null` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grants location. |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | The ARN of the IAM Role which S3 Access Grants assumes to vend temporary credentials for this location. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the S3 Access Grants location. The ID is `default` if the location scope is the default location `s3://`, and is an auto-generated ID for the other locations. |
| <a name="output_instance"></a> [instance](#output\_instance) | The ARN of the S3 Access Grants instance which this location is registered in. |
| <a name="output_location_scope"></a> [location\_scope](#output\_location\_scope) | The S3 URI path of the registered location. |
| <a name="output_name"></a> [name](#output\_name) | The name of the S3 Access Grants location. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
