variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Desired name for the S3 Access Grants location. S3 Access Grants doesn't support to name the location, so this name is only used to name the module resources like the IAM role, the resource tags and the Resource Group."
  type        = string
  nullable    = false
}

variable "instance" {
  description = "(Required) The ARN of the S3 Access Grants instance to register this location in. The S3 Access Grants instance must be in the same region with the location. Used to restrict the trust policy and the permission policy of the default IAM role to the S3 Access Grants instance."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^arn:[^:]+:s3:[^:]*:[0-9]{12}:access-grants/default$", var.instance))
    error_message = "`instance` must be a valid ARN of the S3 Access Grants instance like `arn:aws:s3:us-east-1:111122223333:access-grants/default`."
  }
}

variable "location_scope" {
  description = "(Required) The S3 URI path of the location to register. The location scope can be the default S3 location `s3://`, the S3 path to a bucket `s3://amzn-s3-demo-bucket/`, or the S3 path to a bucket and prefix `s3://amzn-s3-demo-bucket/prefix/`. The default location `s3://` includes all buckets in the region of the account."
  type        = string
  nullable    = false

  validation {
    condition     = startswith(var.location_scope, "s3://")
    error_message = "`location_scope` must be an S3 URI path which starts with `s3://`."
  }
}

variable "iam_role" {
  description = "(Optional) The ARN of the IAM Role which S3 Access Grants assumes to vend temporary credentials for this location. Only required if `default_iam_role.enabled` is `false`. The trust policy of the IAM Role must allow the `access-grants.s3.amazonaws.com` service principal to call `sts:AssumeRole`, `sts:SetSourceIdentity` and `sts:SetContext`."
  type        = string
  default     = null
  nullable    = true
}

variable "default_iam_role" {
  description = <<EOF
  (Optional) A configurations of the default IAM Role which S3 Access Grants assumes to vend temporary credentials for this location. Use `iam_role` if `default_iam_role.enabled` is `false`. The permissions of the default IAM Role are the ceiling of all grants of this location, and are automatically scoped down to the `location_scope`. `default_iam_role` as defined below.
    (Optional) `enabled` - Whether to create the default IAM Role. Defaults to `true`.
    (Optional) `name` - The name of the default IAM Role. Defaults to `s3-access-grants-$${var.name}`.
    (Optional) `path` - The path of the default IAM Role. Defaults to `/`.
    (Optional) `description` - The description of the default IAM Role.
    (Optional) `max_session_duration` - The maximum session duration (in seconds) of the default IAM Role. S3 Access Grants can't vend credentials which live longer than this duration. Valid value is from 1 hour (`3600`) to 12 hours (`43200`). Defaults to `3600`.
    (Optional) `permission` - The maximum level of access to the S3 data of this location. Grants of this location can only narrow down this permission. Valid values are `READ`, `WRITE` and `READWRITE`. Defaults to `READWRITE`.
    (Optional) `object_acl_enabled` - Whether to add the permissions for the S3 object ACL (Access Control List) to the default IAM Role. Not required if the buckets of this location disable ACLs with the `BucketOwnerEnforced` object ownership. Defaults to `false`.
    (Optional) `kms_keys` - A set of ARNs of the AWS KMS keys which encrypt the S3 data of this location. Required to vend credentials for the `SSE-KMS` encrypted objects. The key policy of each AWS KMS key also need to allow the default IAM Role. Defaults to `[]`.
    (Optional) `policies` - A set of IAM policy ARNs to attach to the default IAM Role. Defaults to `[]`.
    (Optional) `inline_policies` - A map of inline IAM policies to attach to the default IAM Role. (`name` => `policy`). Use this to add the permissions which are not covered by the generated policy like the explicit denies for the non-TLS requests.
    (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default IAM Role.
  EOF
  type = object({
    enabled              = optional(bool, true)
    name                 = optional(string)
    path                 = optional(string, "/")
    description          = optional(string, "Managed by Terraform.")
    max_session_duration = optional(number, 3600)

    permission         = optional(string, "READWRITE")
    object_acl_enabled = optional(bool, false)
    kms_keys           = optional(set(string), [])

    policies             = optional(set(string), [])
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
    condition = alltrue([
      var.default_iam_role.max_session_duration >= 3600,
      var.default_iam_role.max_session_duration <= 43200,
    ])
    error_message = "`default_iam_role.max_session_duration` must be between `3600` and `43200`."
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
