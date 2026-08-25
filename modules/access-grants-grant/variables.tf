variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) A name of the S3 Access Grant. The name is only used for the `Name` tag and module metadata."
  type        = string
  nullable    = false
}

variable "location_id" {
  description = "(Required) The ID of the S3 Access Grants location to which the access grant is giving access. `default` is the ID of the location of the default S3 URI `s3://`."
  type        = string
  nullable    = false
}

variable "s3_sub_prefix" {
  description = "(Optional) The sub-prefix appended to the scope of the registered location to narrow the scope of the access grant. Required if `location_id` is `default` (the location of the default S3 URI `s3://`). For example, if the location scope is `s3://bucket/prefix`, provide `prefix2/*` to create a grant scope of `s3://bucket/prefix/prefix2/*`."
  type        = string
  default     = null
  nullable    = true
}

variable "object_grant_enabled" {
  description = "(Optional) Whether the access grant gives access to only one object. Enable this to set `s3_prefix_type` of the access grant to `Object`. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "permission" {
  description = "(Required) The level of access to be given to the grantee within the grant scope. Valid values are `READ`, `WRITE` and `READWRITE`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["READ", "WRITE", "READWRITE"], var.permission)
    error_message = "Valid values for `permission` are `READ`, `WRITE`, `READWRITE`."
  }
}

variable "grantee" {
  description = <<EOF
  (Required) A configuration of the grantee to which the access is given. `grantee` as defined below.
    (Required) `type` - The type of the grantee. Valid values are as follows. `DIRECTORY_USER` and `DIRECTORY_GROUP` require the S3 Access Grants instance to be associated with an AWS IAM Identity Center instance.
    - `IAM` - An IAM user or role ARN of the same or a different AWS account.
    - `DIRECTORY_USER` - A user GUID of the associated AWS IAM Identity Center instance.
    - `DIRECTORY_GROUP` - A group GUID of the associated AWS IAM Identity Center instance.
    (Required) `identifier` - The identifier of the grantee. An IAM user or role ARN if `type` is `IAM`, a user or group GUID if `type` is `DIRECTORY_USER` or `DIRECTORY_GROUP`.
  EOF
  type = object({
    type       = string
    identifier = string
  })
  nullable = false

  validation {
    condition     = contains(["IAM", "DIRECTORY_USER", "DIRECTORY_GROUP"], var.grantee.type)
    error_message = "Valid values for `grantee.type` are `IAM`, `DIRECTORY_USER`, `DIRECTORY_GROUP`."
  }
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
