# access-grants-location

This module creates following resources.

- `aws_s3control_access_grants_location`
- `aws_iam_role` and its policies (optional)

The location and its runtime IAM role share a lifecycle. Grants are intentionally managed by the separate `access-grant` module.

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
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3control_access_grants_location.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_grants_location) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_grants_instance_arn"></a> [access\_grants\_instance\_arn](#input\_access\_grants\_instance\_arn) | (Required) The ARN of the S3 Access Grants instance. Used to scope the trust policy of a created location IAM role and to enforce the instance-to-location dependency. | `string` | n/a | yes |
| <a name="input_location_scope"></a> [location\_scope](#input\_location\_scope) | (Required) The S3 URI of the registered location. Use `s3://` for the default location, or an S3 bucket or prefix URI for a custom location. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the module instance. Used for module metadata, the default IAM role name, and the Resource Group name. | `string` | n/a | yes |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | (Optional) A configuration for the IAM role assumed by S3 Access Grants. `iam_role` as defined below.<br/>    (Optional) `enabled` - Whether to create the IAM role. Defaults to `true`.<br/>    (Optional) `name` - The IAM role name. Defaults to `s3-access-grants-${var.name}`.<br/>    (Optional) `path` - The IAM role path. Defaults to `/`.<br/>    (Optional) `description` - The IAM role description. Defaults to `Managed by Terraform.`.<br/>    (Optional) `policies` - A set of IAM managed policy ARNs to attach to the role.<br/>    (Optional) `inline_policies` - A map of inline policy names to JSON policy documents. Use these policies to define the maximum S3 and KMS permissions for the location.<br/>    (Optional) `permissions_boundary` - The ARN of the permissions boundary for the role. | <pre>object({<br/>    enabled              = optional(bool, true)<br/>    name                 = optional(string)<br/>    path                 = optional(string, "/")<br/>    description          = optional(string, "Managed by Terraform.")<br/>    policies             = optional(set(string), [])<br/>    inline_policies      = optional(map(string), {})<br/>    permissions_boundary = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | (Optional) The ARN of an existing IAM role that S3 Access Grants assumes for this location. Required when `iam_role.enabled` is `false`. | `string` | `null` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grants location. |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | The IAM role assumed by S3 Access Grants for this location. |
| <a name="output_id"></a> [id](#output\_id) | The unique ID of the S3 Access Grants location. |
| <a name="output_name"></a> [name](#output\_name) | The name of this module instance. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_scope"></a> [scope](#output\_scope) | The S3 URI registered as the location scope. |
<!-- END_TF_DOCS -->
