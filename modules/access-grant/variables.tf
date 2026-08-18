variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Desired name for the S3 Access Grant. S3 Access Grants doesn't support to name the grant, so this name is only used to name the module resources like the resource tags and the Resource Group."
  type        = string
  nullable    = false
}

variable "location" {
  description = "(Required) The ID of the S3 Access Grants location to grant access to. The ID is `default` for the default location `s3://`, and is an auto-generated ID for the other locations. Not the ARN of the S3 Access Grants location."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,64}$", var.location))
    error_message = "`location` must be the ID of the S3 Access Grants location which consists of up to 64 letters, numbers and hyphens."
  }
}

variable "grantee" {
  description = <<EOF
  (Required) A configurations of the grantee which receives the access to the S3 data. `grantee` as defined below.
    (Required) `type` - The type of the grantee. Valid values are `IAM`, `DIRECTORY_USER` and `DIRECTORY_GROUP`. `DIRECTORY_USER` and `DIRECTORY_GROUP` are only supported if the S3 Access Grants instance is associated with an IAM Identity Center instance.
    (Required) `identifier` - The identifier of the grantee. The ARN of an IAM user or role if the value of `grantee.type` is `IAM`. The ID (GUID) of an IAM Identity Center user or group if the value of `grantee.type` is `DIRECTORY_USER` or `DIRECTORY_GROUP`.
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
  description = "(Required) The level of access to grant to the S3 data. Valid values are `READ`, `WRITE` and `READWRITE`. `READ` grants read-only access, `WRITE` grants write-only access which also includes the delete operations, and `READWRITE` grants both read and write access."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["READ", "WRITE", "READWRITE"], var.permission)
    error_message = "Valid values for `permission` are `READ`, `WRITE`, `READWRITE`."
  }
}

variable "scope" {
  description = <<EOF
  (Optional) A configurations of the scope of the S3 Access Grant. The grant scope is the result of appending `scope.sub_prefix` to the location scope of the registered location. `scope` as defined below.
    (Optional) `type` - The type of the grant scope. Valid values are `PREFIX` and `OBJECT`. Use `OBJECT` to grant access to a single S3 object. Defaults to `PREFIX`.
    (Optional) `sub_prefix` - The S3 sub prefix which is appended to the location scope to narrow the grant scope to a subset of the location scope. Append the wildcard character `*` after the prefix to include all object key names which start with the prefix. (e.g. `marketing/*` of the `s3://amzn-s3-demo-bucket/` location makes the grant scope `s3://amzn-s3-demo-bucket/marketing/*`) Required if the location scope is the default location `s3://` because you cannot create a grant for all of your S3 data in the region.
  EOF
  type = object({
    type       = optional(string, "PREFIX")
    sub_prefix = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["PREFIX", "OBJECT"], var.scope.type)
    error_message = "Valid values for `scope.type` are `PREFIX`, `OBJECT`."
  }
  validation {
    condition     = var.scope.type != "OBJECT" || var.scope.sub_prefix != null
    error_message = "`scope.sub_prefix` is required if the value of `scope.type` is `OBJECT`."
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
