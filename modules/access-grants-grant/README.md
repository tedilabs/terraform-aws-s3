# access-grants-grant

This module creates following resources.

- `aws_s3control_access_grant`

## Notes

- The access grant only narrows down the access which the IAM role of the S3 Access Grants location allows — it can never widen it. Explicit `Deny` statements in bucket policies, SCPs and VPC endpoint policies always take precedence.
- A grant for the location of the default S3 URI (`s3://`, location ID `default`) cannot cover the entire default location — `s3_sub_prefix` with a bucket (and optionally a prefix) is required.
- `DIRECTORY_USER` and `DIRECTORY_GROUP` grantees require the S3 Access Grants instance to be associated with an AWS IAM Identity Center instance. Prefer group grants over individual user grants to keep the number of grants manageable (up to 100,000 grants per instance by default).
- The grantee obtains temporary credentials with the `s3control:GetDataAccess` API, and accesses S3 with the vended credentials. Existing IAM based access paths are not affected by creating a grant.

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
| [aws_s3control_access_grant.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_grant) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_grantee"></a> [grantee](#input\_grantee) | (Required) A configuration of the grantee to which the access is given. `grantee` as defined below.<br/>    (Required) `type` - The type of the grantee. Valid values are as follows. `DIRECTORY_USER` and `DIRECTORY_GROUP` require the S3 Access Grants instance to be associated with an AWS IAM Identity Center instance.<br/>    - `IAM` - An IAM user or role ARN of the same or a different AWS account.<br/>    - `DIRECTORY_USER` - A user GUID of the associated AWS IAM Identity Center instance.<br/>    - `DIRECTORY_GROUP` - A group GUID of the associated AWS IAM Identity Center instance.<br/>    (Required) `identifier` - The identifier of the grantee. An IAM user or role ARN if `type` is `IAM`, a user or group GUID if `type` is `DIRECTORY_USER` or `DIRECTORY_GROUP`. | <pre>object({<br/>    type       = string<br/>    identifier = string<br/>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The ID of the S3 Access Grants location to which the access grant is giving access. `default` is the ID of the location of the default S3 URI `s3://`. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) A name of the S3 Access Grant. The name is only used for the `Name` tag and module metadata. | `string` | n/a | yes |
| <a name="input_permission"></a> [permission](#input\_permission) | (Required) The level of access to be given to the grantee within the grant scope. Valid values are `READ`, `WRITE` and `READWRITE`. | `string` | n/a | yes |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | (Optional) A configurations of the scope of the S3 Access Grant. The grant scope is the result of appending `scope.sub_prefix` to the location scope of the registered location. `scope` as defined below.<br/>    (Optional) `type` - The type of the grant scope. Valid values are `PREFIX` and `OBJECT`. Use `OBJECT` to grant access to a single S3 object. Defaults to `PREFIX`.<br/>    (Optional) `sub_prefix` - The S3 sub prefix which is appended to the location scope to narrow the grant scope to a subset of the location scope. Append the wildcard character `*` after the prefix to include all object key names which start with the prefix. (e.g. `marketing/*` of the `s3://amzn-s3-demo-bucket/` location makes the grant scope `s3://amzn-s3-demo-bucket/marketing/*`) Required if the location scope is the default location `s3://` because you cannot create a grant for all of your S3 data in the region. | <pre>object({<br/>    type       = optional(string, "PREFIX")<br/>    sub_prefix = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grant. |
| <a name="output_grantee"></a> [grantee](#output\_grantee) | The grantee to which the access is given. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the S3 Access Grant. |
| <a name="output_location"></a> [location](#output\_location) | The S3 Access Grants location to which the access grant is giving access.<br/>     `id` - The ID of the S3 Access Grants location. |
| <a name="output_name"></a> [name](#output\_name) | The name of the S3 Access Grant. |
| <a name="output_owner"></a> [owner](#output\_owner) | The AWS account ID of the owner of the S3 Access Grant. |
| <a name="output_permission"></a> [permission](#output\_permission) | The level of access given to the grantee within the grant scope. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_scope"></a> [scope](#output\_scope) | The scope of the S3 Access Grant. |
<!-- END_TF_DOCS -->
