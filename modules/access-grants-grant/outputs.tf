output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grant.this.region
}

output "owner" {
  description = "The account ID of the account that owns the S3 Access Grants instance of this grant."
  value       = aws_s3control_access_grant.this.account_id
}

output "id" {
  description = "The ID of the S3 Access Grant."
  value       = aws_s3control_access_grant.this.access_grant_id
}

output "arn" {
  description = "The ARN of the S3 Access Grant."
  value       = aws_s3control_access_grant.this.access_grant_arn
}

output "location" {
  description = "The ID of the S3 Access Grants location which this grant is created in."
  value       = aws_s3control_access_grant.this.access_grants_location_id
}

output "permission" {
  description = "The level of access which is granted to the S3 data."
  value       = aws_s3control_access_grant.this.permission
}

output "grantee" {
  description = "The grantee which receives the access to the S3 data."
  value = {
    type       = one(aws_s3control_access_grant.this.grantee[*].grantee_type)
    identifier = one(aws_s3control_access_grant.this.grantee[*].grantee_identifier)
  }
}

output "scope" {
  description = "The scope of the S3 Access Grant."
  value = {
    type       = aws_s3control_access_grant.this.s3_prefix_type == local.prefix_type["OBJECT"] ? "OBJECT" : "PREFIX"
    sub_prefix = one(aws_s3control_access_grant.this.access_grants_location_configuration[*].s3_sub_prefix)
    path       = aws_s3control_access_grant.this.grant_scope
  }
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
