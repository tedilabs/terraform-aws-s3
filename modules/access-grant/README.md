# access-grant

This module creates following resources.

- `aws_s3control_access_grant`

Manage grants separately from the regional instance and dataset location so permission approvals can follow their own deployment lifecycle.

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

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_grantee"></a> [grantee](#input\_grantee) | (Required) The identity receiving access. `grantee` as defined below.<br/>    (Required) `type` - The grantee type. Valid values are `IAM`, `DIRECTORY_USER`, and `DIRECTORY_GROUP`.<br/>    (Required) `identifier` - The IAM principal ARN or IAM Identity Center user or group GUID. | <pre>object({<br/>    type       = string<br/>    identifier = string<br/>  })</pre> | n/a | yes |
| <a name="input_location_id"></a> [location\_id](#input\_location\_id) | (Required) The unique ID of the S3 Access Grants location to which this grant applies. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the module instance. Used for module metadata and the Resource Group name. | `string` | n/a | yes |
| <a name="input_permission"></a> [permission](#input\_permission) | (Required) The level of access granted. Valid values are `READ`, `WRITE`, and `READWRITE`. | `string` | n/a | yes |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_s3_prefix_type"></a> [s3\_prefix\_type](#input\_s3\_prefix\_type) | (Optional) Set to `Object` when granting access to exactly one S3 object. | `string` | `null` | no |
| <a name="input_s3_sub_prefix"></a> [s3\_sub\_prefix](#input\_s3\_sub\_prefix) | (Optional) A sub-prefix appended to the registered location scope to narrow this grant. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grant. |
| <a name="output_grantee"></a> [grantee](#output\_grantee) | The identity receiving access. |
| <a name="output_id"></a> [id](#output\_id) | The unique ID of the S3 Access Grant. |
| <a name="output_name"></a> [name](#output\_name) | The name of this module instance. |
| <a name="output_permission"></a> [permission](#output\_permission) | The level of access granted. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_scope"></a> [scope](#output\_scope) | The effective scope of the S3 Access Grant. |
<!-- END_TF_DOCS -->
