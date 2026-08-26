output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grants_instance.this.region
}

output "name" {
  description = "The name of the S3 Access Grants instance."
  value       = local.metadata.name
}

output "id" {
  description = "The ID of the S3 Access Grants instance."
  value       = aws_s3control_access_grants_instance.this.access_grants_instance_id
}

output "arn" {
  description = "The ARN of the S3 Access Grants instance."
  value       = aws_s3control_access_grants_instance.this.access_grants_instance_arn
}

output "iam_identity_center" {
  description = "The configuration of the AWS IAM Identity Center association for the S3 Access Grants instance."
  value = {
    enabled     = aws_s3control_access_grants_instance.this.identity_center_arn != null
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

output "sharing" {
  description = <<EOF
  The configuration for sharing of the S3 Access Grants instance.
    `status` - An indication of whether the S3 Access Grants instance is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.
    `shares` - The list of resource shares via RAM (Resource Access Manager).
  EOF
  value = {
    status = length(module.share) > 0 ? "SHARED_BY_ME" : "NOT_SHARED"
    shares = module.share
  }
}
