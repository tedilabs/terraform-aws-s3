# access-grants-instance

This module creates following resources.

- `aws_s3control_access_grants_instance`
- `aws_s3control_access_grants_instance_resource_policy` (optional)

## Notes

- Only one S3 Access Grants instance can exist per AWS account per Region. The instance is a regional container for Access Grants locations and grants, so the S3 data must be in the same region as the instance.
- Associate an AWS IAM Identity Center instance with `iam_identity_center` to create access grants for users and groups of your corporate directory. The IAM Identity Center instance must be in the same region as the S3 Access Grants instance. If `iam_identity_center.instance` is not provided, the IAM Identity Center instance of the current account is automatically used.
- For cross-account access, sharing the instance with AWS RAM (Resource Access Manager) is recommended over the instance resource policy. Use `policy` only when RAM is not an option.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.57 |

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
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssoadmin_instances.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_iam_identity_center"></a> [iam\_identity\_center](#input\_iam\_identity\_center) | (Optional) A configurations of the IAM Identity Center association for the S3 Access Grants instance. Associate an IAM Identity Center instance to create grants for corporate directory users and groups. `iam_identity_center` as defined below.<br/>    (Optional) `enabled` - Whether to associate an IAM Identity Center instance with the S3 Access Grants instance. Defaults to `false`.<br/>    (Optional) `instance` - The ARN of the IAM Identity Center instance to associate with the S3 Access Grants instance. The IAM Identity Center instance must be in the same region with the S3 Access Grants instance. If not provided, the IAM Identity Center instance of the current account is automatically used. | <pre>object({<br/>    enabled  = optional(bool, false)<br/>    instance = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid resource policy JSON document for the S3 Access Grants instance. Use this to share the S3 Access Grants instance with other AWS accounts without AWS RAM (Resource Access Manager). Although this is a resource policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grants instance. |
| <a name="output_iam_identity_center"></a> [iam\_identity\_center](#output\_iam\_identity\_center) | The configuration of the AWS IAM Identity Center association for the S3 Access Grants instance. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the S3 Access Grants instance. |
| <a name="output_name"></a> [name](#output\_name) | The name of the S3 Access Grants instance. |
| <a name="output_policy"></a> [policy](#output\_policy) | The resource policy of the S3 Access Grants instance. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
