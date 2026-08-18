# access-grants-instance

This module creates following resources.

- `aws_s3control_access_grants_instance`
- `aws_s3control_access_grants_instance_resource_policy` (optional)

Only one S3 Access Grants instance can exist per AWS account and region. Keep this module in platform-level state, separate from locations and grants.

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
| [aws_s3control_access_grants_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_grants_instance) | resource |
| [aws_s3control_access_grants_instance_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_grants_instance_resource_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the module instance. Used for module metadata and the Resource Group name. | `string` | n/a | yes |
| <a name="input_identity_center_arn"></a> [identity\_center\_arn](#input\_identity\_center\_arn) | (Optional) The ARN of the IAM Identity Center instance to associate with the S3 Access Grants instance. The Identity Center instance must be in the same region. | `string` | `null` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid resource policy JSON document for cross-account access to the S3 Access Grants instance. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grants instance. |
| <a name="output_id"></a> [id](#output\_id) | The unique ID of the S3 Access Grants instance. |
| <a name="output_identity_center"></a> [identity\_center](#output\_identity\_center) | The IAM Identity Center association of the S3 Access Grants instance. |
| <a name="output_name"></a> [name](#output\_name) | The name of this module instance. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
