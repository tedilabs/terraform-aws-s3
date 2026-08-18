# access-grants-instance

This module creates following resources.

- `aws_s3control_access_grants_instance`
- `aws_s3control_access_grants_instance_resource_policy` (optional)

## Notes

- The S3 Access Grants instance is a singleton of the region of the account. You can create only one instance per region per account, and the ID of the instance is always `default`. Own this module in the platform workspace and share the instance ARN with the workspaces which register locations and create grants.
- The S3 Access Grants instance must be in the same region with the S3 data of its locations. Deploy the module once per region with the provider `alias` or the `region` variable.
- The associated IAM Identity Center instance must be in the same region with the S3 Access Grants instance. The association is required to create grants for the corporate directory users and groups (`DIRECTORY_USER`, `DIRECTORY_GROUP`).
- The S3 Access Grants instance can't be deleted until all of its locations and grants are deleted.
- `policy` is the resource policy of the S3 Access Grants instance which grants other AWS accounts access to the instance for the cross-account use cases. Sharing the instance with AWS RAM (`aws_ram_resource_share`) is the alternative of the resource policy, and is not managed by this module.
- Cross-account access requires all of the following. Sharing the S3 Access Grants instance alone doesn't grant access to the S3 data.
  - the access to the S3 Access Grants instance with the resource policy or AWS RAM
  - the `s3:GetDataAccess` permission of the caller in the consumer account
  - the grant of the data with the IAM role of the consumer account as a grantee

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
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_iam_identity_center"></a> [iam\_identity\_center](#input\_iam\_identity\_center) | (Optional) A configurations of the IAM Identity Center association for the S3 Access Grants instance. Associate an IAM Identity Center instance to create grants for corporate directory users and groups. `iam_identity_center` as defined below.<br/>    (Optional) `enabled` - Whether to associate an IAM Identity Center instance with the S3 Access Grants instance. Defaults to `false`.<br/>    (Optional) `instance` - The ARN of the IAM Identity Center instance to associate with the S3 Access Grants instance. The IAM Identity Center instance must be in the same region with the S3 Access Grants instance. Only required if `iam_identity_center.enabled` is `true`. | <pre>object({<br/>    enabled  = optional(bool, false)<br/>    instance = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid resource policy JSON document for the S3 Access Grants instance. The resource policy grants other AWS accounts access to the S3 Access Grants instance for the cross-account use cases. Although this is a resource policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Grants instance. |
| <a name="output_iam_identity_center"></a> [iam\_identity\_center](#output\_iam\_identity\_center) | The configuration for the IAM Identity Center association of the S3 Access Grants instance. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the S3 Access Grants instance. The ID is always `default` because you can have one S3 Access Grants instance per region per account. |
| <a name="output_owner"></a> [owner](#output\_owner) | The account ID of the account that owns the S3 Access Grants instance. |
| <a name="output_policy"></a> [policy](#output\_policy) | The resource policy of the S3 Access Grants instance. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
