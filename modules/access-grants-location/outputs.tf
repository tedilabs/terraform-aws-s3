output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grants_location.this.region
}

output "name" {
  description = "The name of the S3 Access Grants location."
  value       = local.metadata.name
}

output "id" {
  description = "The ID of the S3 Access Grants location. `default` is assigned to the location of the default S3 URI `s3://`."
  value       = aws_s3control_access_grants_location.this.access_grants_location_id
}

output "arn" {
  description = "The ARN of the S3 Access Grants location."
  value       = aws_s3control_access_grants_location.this.access_grants_location_arn
}

output "location_scope" {
  description = "The S3 URI of the registered location."
  value       = aws_s3control_access_grants_location.this.location_scope
}

output "iam_role" {
  description = "The ARN of the IAM role that S3 Access Grants assumes to vend temporary credentials for the location."
  value       = aws_s3control_access_grants_location.this.iam_role_arn
}

output "default_iam_role" {
  description = "The configuration of the default IAM role created for the S3 Access Grants location."
  value = merge(
    {
      enabled = var.default_iam_role.enabled
    },
    (var.default_iam_role.enabled
      ? {
        arn        = aws_iam_role.this[0].arn
        name       = aws_iam_role.this[0].name
        permission = var.default_iam_role.permission
        kms_keys   = var.default_iam_role.kms_keys
      }
      : {}
    )
  )
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}
