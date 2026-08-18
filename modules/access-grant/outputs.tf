output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grant.this.region
}

output "name" {
  description = "The name of this module instance."
  value       = var.name
}

output "id" {
  description = "The unique ID of the S3 Access Grant."
  value       = aws_s3control_access_grant.this.access_grant_id
}

output "arn" {
  description = "The ARN of the S3 Access Grant."
  value       = aws_s3control_access_grant.this.access_grant_arn
}

output "scope" {
  description = "The effective scope of the S3 Access Grant."
  value       = aws_s3control_access_grant.this.grant_scope
}

output "permission" {
  description = "The level of access granted."
  value       = aws_s3control_access_grant.this.permission
}

output "grantee" {
  description = "The identity receiving access."
  value = {
    type       = aws_s3control_access_grant.this.grantee[0].grantee_type
    identifier = aws_s3control_access_grant.this.grantee[0].grantee_identifier
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
