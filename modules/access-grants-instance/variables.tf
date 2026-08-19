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
    (Optional) `instance` - The ARN of the IAM Identity Center instance to associate with the S3 Access Grants instance. The IAM Identity Center instance must be in the same region with the S3 Access Grants instance. If not provided, the IAM Identity Center instance of the current account is automatically used.
  EOF
  type = object({
    enabled  = optional(bool, false)
    instance = optional(string)
  })
  default  = {}
  nullable = false
}

variable "policy" {
  description = "(Optional) A valid resource policy JSON document for the S3 Access Grants instance. Use this to share the S3 Access Grants instance with other AWS accounts without AWS RAM (Resource Access Manager). Although this is a resource policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal."
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


###################################################
# Resource Sharing by RAM (Resource Access Manager)
###################################################

variable "shares" {
  description = <<EOF
  (Optional) A list of resource shares via RAM (Resource Access Manager). `shares` as defined below.
    (Optional) `name` - The name of the resource share.
    (Optional) `permissions` - A set of AWS RAM managed permissions to associate with the resource share. Defaults to `AWSRAMPermissionAccessGrantsData`. The following permissions are available for S3 Access Grants:
      `AWSRAMPermissionAccessGrantsData` - Allows principals to request data access credentials and find or list the grants available to the caller. Use this default permission when consumers only need to access data through S3 Access Grants.
      `AWSRAMPermissionAccessGrantsReadAccess` - Includes the data access permissions and allows principals to list all grants and registered locations in the shared instance. Use this when consumers need data access and read-only visibility into the instance configuration.
      `AWSRAMPermissionAccessGrantsControl` - Allows principals to list grants and registered locations without requesting data access credentials. Use this when consumers only need read-only visibility into the instance control plane.
    (Optional) `external_principals_allowed` - Whether to allow principals outside of the AWS Organization to associate with the resource share. Defaults to `false`.
    (Optional) `principals` - A set of principals to associate with the resource share. Defaults to `[]`.
    (Optional) `tags` - A map of tags to add to the resource share. Defaults to `{}`.
  EOF
  type = list(object({
    name = optional(string)

    permissions = optional(set(string), ["AWSRAMPermissionAccessGrantsData"])

    external_principals_allowed = optional(bool, false)
    principals                  = optional(set(string), [])

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false
}
