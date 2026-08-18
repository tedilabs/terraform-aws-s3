variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Desired name for the module instance. Used for module metadata and the Resource Group name."
  type        = string
  nullable    = false
}

variable "location_id" {
  description = "(Required) The unique ID of the S3 Access Grants location to which this grant applies."
  type        = string
  nullable    = false
}

variable "grantee" {
  description = <<EOF
  (Required) The identity receiving access. `grantee` as defined below.
    (Required) `type` - The grantee type. Valid values are `IAM`, `DIRECTORY_USER`, and `DIRECTORY_GROUP`.
    (Required) `identifier` - The IAM principal ARN or IAM Identity Center user or group GUID.
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

variable "permission" {
  description = "(Required) The level of access granted. Valid values are `READ`, `WRITE`, and `READWRITE`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["READ", "WRITE", "READWRITE"], var.permission)
    error_message = "Valid values for `permission` are `READ`, `WRITE`, `READWRITE`."
  }
}

variable "s3_sub_prefix" {
  description = "(Optional) A sub-prefix appended to the registered location scope to narrow this grant."
  type        = string
  default     = null
  nullable    = true
}

variable "s3_prefix_type" {
  description = "(Optional) Set to `Object` when granting access to exactly one S3 object."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.s3_prefix_type == null || var.s3_prefix_type == "Object"
    error_message = "The only valid value for `s3_prefix_type` is `Object`."
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

variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. If not provided, a name will be generated using the module name and instance name.
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
