variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "scope" {
  description = "(Optional) The S3 URI of the location to register. The default S3 URI `s3://` covers all S3 buckets in the current AWS account in the region. Use `s3://<bucket>` for a specific bucket, or `s3://<bucket>/<prefix>` for a specific prefix of the bucket. The S3 data must be in the same region as the S3 Access Grants instance. Defaults to `s3://`."
  type        = string
  nullable    = false
  default     = "s3://"

  validation {
    condition     = startswith(var.scope, "s3://")
    error_message = "`scope` must be a valid S3 URI starting with `s3://`."
  }
}

variable "iam_role" {
  description = "(Optional) The ARN (Amazon Resource Name) of the IAM role that S3 Access Grants assumes to vend temporary credentials for the location. Only required if `default_iam_role.enabled` is `false`."
  type        = string
  default     = null
  nullable    = true
}

variable "default_iam_role" {
  description = <<EOF
  (Optional) A configuration for the default IAM role for the S3 Access Grants location. S3 Access Grants assumes this role to vend temporary credentials scoped down to the individual grant. The trust policy only allows the S3 Access Grants service principal of the current account, and the permissions follow the AWS recommended policy scoped to `scope`. Use `iam_role` if `default_iam_role.enabled` is `false`. `default_iam_role` as defined below.
    (Optional) `enabled` - Whether to create the default IAM role. Defaults to `true`.
    (Optional) `name` - The name of the default IAM role. If not provided, a name will be generated from the location scope.
    (Optional) `path` - The path of the default IAM role. Defaults to `/`.
    (Optional) `description` - The description of the default IAM role.
    (Optional) `permission` - The maximum level of access which the role allows within the location scope. Access grants for the location can only narrow this down. Valid values are `READ`, `WRITE` and `READWRITE`. Defaults to `READWRITE`.
    (Optional) `sse_kms_keys` - A set of ARNs of AWS KMS keys to allow the role to use for `SSE-KMS` encrypted objects within the location scope. Defaults to `[]`.
    (Optional) `policies` - A list of IAM policy ARNs to attach to the default IAM role. Defaults to `[]`.
    (Optional) `inline_policies` - A Map of inline IAM policies to attach to the default IAM role. (`name` => `policy`).
    (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default IAM role.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    path        = optional(string, "/")
    description = optional(string, "Managed by Terraform.")

    permission   = optional(string, "READWRITE")
    sse_kms_keys = optional(set(string), [])

    policies             = optional(list(string), [])
    inline_policies      = optional(map(string), {})
    permissions_boundary = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["READ", "WRITE", "READWRITE"], var.default_iam_role.permission)
    error_message = "Valid values for `default_iam_role.permission` are `READ`, `WRITE`, `READWRITE`."
  }
  validation {
    condition = (var.default_iam_role.enabled
      || var.iam_role != null
    )
    error_message = "`iam_role` is required if `default_iam_role.enabled` is `false`."
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
