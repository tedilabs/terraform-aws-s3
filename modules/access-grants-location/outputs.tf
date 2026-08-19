output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grants_location.this.region
}

output "name" {
  description = "The name of the S3 Access Grants location."
  value       = local.metadata.name
}

output "id" {
  description = "The ID of the S3 Access Grants location. The ID is `default` if the location scope is the default location `s3://`, and is an auto-generated ID for the other locations."
  value       = aws_s3control_access_grants_location.this.access_grants_location_id
}

output "arn" {
  description = "The ARN of the S3 Access Grants location."
  value       = aws_s3control_access_grants_location.this.access_grants_location_arn
}

output "instance" {
  description = "The ARN of the S3 Access Grants instance which this location is registered in."
  value       = var.instance
}

output "location_scope" {
  description = "The S3 URI path of the registered location."
  value       = aws_s3control_access_grants_location.this.location_scope
}

output "iam_role" {
  description = "The ARN of the IAM Role which S3 Access Grants assumes to vend temporary credentials for this location."
  value       = aws_s3control_access_grants_location.this.iam_role_arn
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
