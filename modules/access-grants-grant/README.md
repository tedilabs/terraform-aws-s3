# access-grants-grant

This module creates following resources.

- `aws_s3control_access_grant`

## Notes

- The grant scope is the result of appending `scope.sub_prefix` to the location scope of the registered S3 Access Grants location. `scope.sub_prefix` is required if the location is the default location `s3://`, because you cannot create a grant for all of your S3 data in the region.
- A grant can only narrow down the permissions of the IAM role of the registered location, and can't extend them. A `READWRITE` grant of a read-only location is still read-only. Use the `permission` of the `access-grants-location` module to cap all grants of the location.
- Prefer a `DIRECTORY_GROUP` grantee over a `DIRECTORY_USER` grantee to model the permissions of the corporate directory. The membership of the group is managed in the identity provider, so the grants don't need to be updated for the joiners and leavers. `DIRECTORY_USER` and `DIRECTORY_GROUP` grantees require the S3 Access Grants instance to be associated with an IAM Identity Center instance.
- The grantee needs the `s3:GetDataAccess` permission of its own IAM policy to request the temporary credentials. The grant alone doesn't allow the grantee to call `s3:GetDataAccess`.
- All arguments except `tags` force a new grant to be created when changed, because S3 Access Grants doesn't support to update a grant.
- The `application_arn` attribute which limits the grant to a specific IAM Identity Center application is not supported by the AWS provider.
- `name` is only a module-level label. S3 Access Grants generates the ID of a grant, so the module can't derive a unique name for the resource tags and the Resource Group from the AWS resource.
- Set `resource_group.enabled` to `false` if you manage a large number of grants. A Resource Group per grant is rarely useful, and the default quota of the grants (100,000 per instance) is much bigger than the quota of the resource groups.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.62.0 |

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
| <a name="input_grantee"></a> [grantee](#input\_grantee) | (Required) A configurations of the grantee which receives the access to the S3 data. `grantee` as defined below.<br/>    (Required) `type` - The type of the grantee. Valid values are `IAM`, `DIRECTORY_USER` and `DIRECTORY_GROUP`. `DIRECTORY_USER` and `DIRECTORY_GROUP` are only supported if the S3 Access Grants instance is associated with an IAM Identity Center instance.<br/>    (Required) `identifier` - The identifier of the grantee. The ARN of an IAM user or role if the value of `grantee.type` is `IAM`. The ID (GUID) of an IAM Identity Center user or group if the value of `grantee.type` is `DIRECTORY_USER` or `DIRECTORY_GROUP`. | <pre>object({<br/>    type       = string<br/>    identifier = string<br/>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The ID of the S3 Access Grants location to grant access to. The ID is `default` for the default location `s3://`, and is an auto-generated ID for the other locations. Not the ARN of the S3 Access Grants location. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the S3 Access Grant. S3 Access Grants doesn't support to name a grant, so this name is only used to name the module resources like the resource tags and the Resource Group. | `string` | n/a | yes |
| <a name="input_permission"></a> [permission](#input\_permission) | (Required) The level of access to grant to the S3 data. Valid values are `READ`, `WRITE` and `READWRITE`. `READ` grants read-only access, `WRITE` grants write-only access which also includes the delete operations, and `READWRITE` grants both read and write access. | `string` | n/a | yes |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | (Optional) A configurations of the scope of the S3 Access Grant. The grant scope is the result of appending `scope.sub_prefix` to the location scope of the registered location. `scope` as defined below.<br/>    (Optional) `type` - The type of the grant scope. Valid values are `PREFIX` and `OBJECT`. Use `OBJECT` to grant access to a single S3 object. Defaults to `PREFIX`.<br/>    (Optional) `sub_prefix` - The S3 sub prefix which is appended to the location scope to narrow the grant scope to a subset of the location scope. Append the wildcard character `*` after the prefix to include all object key names which start with the prefix. (e.g. `marketing/*` of the `s3://amzn-s3-demo-bucket/` location makes the grant scope `s3://amzn-s3-demo-bucket/marketing/*`) Required if the location scope is the default location `s3://` because you cannot create a grant for all of your S3 data in the region. | <pre>object({<br/>    type       = optional(string, "PREFIX")<br/>    sub_prefix = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grant. |
| <a name="output_grantee"></a> [grantee](#output\_grantee) | The grantee which receives the access to the S3 data. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the S3 Access Grant. |
| <a name="output_location"></a> [location](#output\_location) | The ID of the S3 Access Grants location which this grant is created in. |
| <a name="output_owner"></a> [owner](#output\_owner) | The account ID of the account that owns the S3 Access Grants instance of this grant. |
| <a name="output_permission"></a> [permission](#output\_permission) | The level of access which is granted to the S3 data. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_scope"></a> [scope](#output\_scope) | The scope of the S3 Access Grant. |
<!-- END_TF_DOCS -->
