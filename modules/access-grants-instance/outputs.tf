output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grants_instance.this.region
}

output "name" {
  description = "The name of this module instance."
  value       = var.name
}

output "id" {
  description = "The unique ID of the S3 Access Grants instance."
  value       = aws_s3control_access_grants_instance.this.access_grants_instance_id
}

output "arn" {
  description = "The ARN of the S3 Access Grants instance."
  value       = aws_s3control_access_grants_instance.this.access_grants_instance_arn
}

output "identity_center" {
  description = "The IAM Identity Center association of the S3 Access Grants instance."
  value = {
    instance_arn    = aws_s3control_access_grants_instance.this.identity_center_arn
    application_arn = aws_s3control_access_grants_instance.this.identity_center_application_arn
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
