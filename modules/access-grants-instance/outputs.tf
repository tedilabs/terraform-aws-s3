output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grants_instance.this.region
}

output "id" {
  description = "The ID of the S3 Access Grants instance. The ID is always `default` because you can have one S3 Access Grants instance per region per account."
  value       = aws_s3control_access_grants_instance.this.access_grants_instance_id
}

output "arn" {
  description = "The ARN of the S3 Access Grants instance."
  value       = aws_s3control_access_grants_instance.this.access_grants_instance_arn
}

output "owner" {
  description = "The account ID of the account that owns the S3 Access Grants instance."
  value       = aws_s3control_access_grants_instance.this.account_id
}

output "iam_identity_center" {
  description = "The configuration for the IAM Identity Center association of the S3 Access Grants instance."
  value = {
    enabled     = var.iam_identity_center.enabled
    instance    = aws_s3control_access_grants_instance.this.identity_center_arn
    application = aws_s3control_access_grants_instance.this.identity_center_application_arn
  }
}

output "policy" {
  description = "The resource policy of the S3 Access Grants instance."
  value       = one(aws_s3control_access_grants_instance_resource_policy.this[*].policy)
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
