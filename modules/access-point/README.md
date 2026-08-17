# access-point

This module creates following resources.

- `aws_s3_access_point`
- `aws_s3control_access_point_policy` (optional)

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
| [aws_s3_access_point.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_access_point) | resource |
| [aws_s3control_access_point_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3control_access_point_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | (Required) A configuration of S3 bucket to associate with this access point.<br/>    (Required) `name` - A name of an AWS Partition S3 Bucket or the Amazon Resource Name (ARN) of S3 on Outposts Bucket that you want to associate this access point with.<br/>    (Optional) `account_id` - The AWS account ID associated with the S3 bucket associated with this access point. Only used for creating an access point by using a bucket in a different AWS account. | <pre>object({<br/>    name       = string<br/>    account_id = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) A name you want to assign to this access point. Access point names must be unique within the account for this Region. | `string` | n/a | yes |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Optional) The AWS account ID for the owner of the bucket for which to create the access point. If not provided, the account ID is automatically determined from the AWS provider configuration. | `string` | `null` | no |
| <a name="input_block_public_access"></a> [block\_public\_access](#input\_block\_public\_access) | (Optional) A configurations of Block Public Access for the S3 access point. Public access is granted to buckets and objects through access control lists (ACLs), bucket policies, access point policies, or all. These settings apply only to this Access Point. Before applying these settings, ensure that your applications will work correctly without public access. These settings can’t be edited after the Access Point is created.<br/>    (Optional) `enabled` - Whether to block all public access to S3 access point. Defaults to `true`.<br/>    (Optional) `block_public_acls_enabled` - Block new public ACLs and uploading public objects if true. Always enabled if `block_public_access.enabled` is `true`.<br/>    (Optional) `ignore_public_acls_enabled` - Retroactively remove public access granted through public ACLs. Always enabled if `block_public_access.enabled` is `true`.<br/>    (Optional) `block_public_policy_enabled` - Block new public bucket policies. Always enabled if `block_public_access.enabled` is `true`.<br/>    (Optional) `restrict_public_buckets_enabled` - Retroactivley block public and cross-account access if bucket has public policies. Always enabled if `block_public_access.enabled` is `true`. | <pre>object({<br/>    enabled                         = optional(bool, true)<br/>    block_public_acls_enabled       = optional(bool, false)<br/>    ignore_public_acls_enabled      = optional(bool, false)<br/>    block_public_policy_enabled     = optional(bool, false)<br/>    restrict_public_buckets_enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_network_origin"></a> [network\_origin](#input\_network\_origin) | (Optional) Indicates whether this access point allows access from the public Internet. Valid Values are `VPC` (the access point doesn't allow access from the public Internet) and `INTERNET` (the access point allows access from the public Internet, subject to the access point and bucket access policies). Defaults to `INTERNET`. | `string` | `"INTERNET"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid policy JSON document that specifies the policy for this access point. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Optional) The VPC ID to be only allowed connections to this access point. Only required if `network_origin` is `VPC`. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account ID that owns the S3 Access Point. |
| <a name="output_alias"></a> [alias](#output\_alias) | The alias of the S3 Access Point. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the S3 Access Point. |
| <a name="output_block_public_access"></a> [block\_public\_access](#output\_block\_public\_access) | The configuration for the S3 bucket access control. |
| <a name="output_bucket"></a> [bucket](#output\_bucket) | The bucket associated with this Access Point. |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The DNS domain name of the S3 Access Point in the format `{name-account_id}.s3-accesspoint.{region}.amazonaws.com`. Note: S3 access points only support secure access by HTTPS. HTTP isn't supported. |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | The VPC endpoints for the S3 Access Point. |
| <a name="output_has_public_access_policy"></a> [has\_public\_access\_policy](#output\_has\_public\_access\_policy) | Whether this access point currently has a policy that allows public access. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the S3 Access Point. |
| <a name="output_name"></a> [name](#output\_name) | The name of the S3 Access Point. |
| <a name="output_network_origin"></a> [network\_origin](#output\_network\_origin) | Indicates whether this access point allows access from the public Internet. Values are `VPC` (the access point doesn't allow access from the public Internet) and `INTERNET` (the access point allows access from the public Internet, subject to the access point and bucket access policies). |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID is to be only allowed connections to this access point if `network_origin` is `VPC`. |
<!-- END_TF_DOCS -->
