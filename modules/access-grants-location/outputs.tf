output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grants_location.this.region
}

output "name" {
  description = "The name of this module instance."
  value       = var.name
}

output "id" {
  description = "The unique ID of the S3 Access Grants location."
  value       = aws_s3control_access_grants_location.this.access_grants_location_id
}

output "arn" {
  description = "The ARN of the S3 Access Grants location."
  value       = aws_s3control_access_grants_location.this.access_grants_location_arn
}

output "scope" {
  description = "The S3 URI registered as the location scope."
  value       = aws_s3control_access_grants_location.this.location_scope
}

output "iam_role" {
  description = "The IAM role assumed by S3 Access Grants for this location."
  value = {
    created = var.iam_role.enabled
    arn     = local.iam_role_arn
    name    = var.iam_role.enabled ? aws_iam_role.this[0].name : null
  }
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    { enabled = var.resource_group.enabled && var.module_tags_enabled },
    (var.resource_group.enabled && var.module_tags_enabled
      ? { arn = module.resource_group[0].arn, name = module.resource_group[0].name }
      : {}
    ),
  )
}
