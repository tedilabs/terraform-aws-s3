variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Desired name for the module instance. Used for module metadata, the default IAM role name, and the Resource Group name."
  type        = string
  nullable    = false
}

variable "access_grants_instance_arn" {
  description = "(Required) The ARN of the S3 Access Grants instance. Used to scope the trust policy of a created location IAM role and to enforce the instance-to-location dependency."
  type        = string
  nullable    = false
}

variable "location_scope" {
  description = "(Required) The S3 URI of the registered location. Use `s3://` for the default location, or an S3 bucket or prefix URI for a custom location."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^s3://", var.location_scope))
    error_message = "`location_scope` must be an S3 URI beginning with `s3://`."
  }
}

variable "iam_role_arn" {
  description = "(Optional) The ARN of an existing IAM role that S3 Access Grants assumes for this location. Required when `iam_role.enabled` is `false`."
  type        = string
  default     = null
  nullable    = true
}

variable "iam_role" {
  description = <<EOF
  (Optional) A configuration for the IAM role assumed by S3 Access Grants. `iam_role` as defined below.
    (Optional) `enabled` - Whether to create the IAM role. Defaults to `true`.
    (Optional) `name` - The IAM role name. Defaults to `s3-access-grants-$${var.name}`.
    (Optional) `path` - The IAM role path. Defaults to `/`.
    (Optional) `description` - The IAM role description. Defaults to `Managed by Terraform.`.
    (Optional) `policies` - A set of IAM managed policy ARNs to attach to the role.
    (Optional) `inline_policies` - A map of inline policy names to JSON policy documents. Use these policies to define the maximum S3 and KMS permissions for the location.
    (Optional) `permissions_boundary` - The ARN of the permissions boundary for the role.
  EOF
  type = object({
    enabled              = optional(bool, true)
    name                 = optional(string)
    path                 = optional(string, "/")
    description          = optional(string, "Managed by Terraform.")
    policies             = optional(set(string), [])
    inline_policies      = optional(map(string), {})
    permissions_boundary = optional(string)
  })
  default  = {}
  nullable = false
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
