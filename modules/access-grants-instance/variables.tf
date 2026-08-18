variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "iam_identity_center" {
  description = <<EOF
  (Optional) A configurations of the IAM Identity Center association for the S3 Access Grants instance. Associate an IAM Identity Center instance to create grants for corporate directory users and groups. `iam_identity_center` as defined below.
    (Optional) `enabled` - Whether to associate an IAM Identity Center instance with the S3 Access Grants instance. Defaults to `false`.
    (Optional) `instance` - The ARN of the IAM Identity Center instance to associate with the S3 Access Grants instance. The IAM Identity Center instance must be in the same region with the S3 Access Grants instance. Only required if `iam_identity_center.enabled` is `true`.
  EOF
  type = object({
    enabled  = optional(bool, false)
    instance = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = !var.iam_identity_center.enabled || var.iam_identity_center.instance != null
    error_message = "`iam_identity_center.instance` is required if `iam_identity_center.enabled` is `true`."
  }
}

variable "policy" {
  description = "(Optional) A valid resource policy JSON document for the S3 Access Grants instance. The resource policy grants other AWS accounts access to the S3 Access Grants instance for the cross-account use cases. Although this is a resource policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}
