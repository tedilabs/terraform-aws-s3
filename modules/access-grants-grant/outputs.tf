output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3control_access_grant.this.region
}

output "name" {
  description = "The name of the S3 Access Grant."
  value       = local.metadata.name
}

output "id" {
  description = "The ID of the S3 Access Grant."
  value       = aws_s3control_access_grant.this.access_grant_id
}

output "arn" {
  description = "The ARN of the S3 Access Grant."
  value       = aws_s3control_access_grant.this.access_grant_arn
}

output "owner" {
  description = "The AWS account ID of the owner of the S3 Access Grant."
  value       = aws_s3control_access_grant.this.account_id
}

output "location" {
  description = <<EOF
  The S3 Access Grants location to which the access grant is giving access.
     `id` - The ID of the S3 Access Grants location.
  EOF
  value = {
    id = aws_s3control_access_grant.this.access_grants_location_id
  }
}

output "permission" {
  description = "The level of access given to the grantee within the grant scope."
  value       = aws_s3control_access_grant.this.permission
}

output "scope" {
  description = "The scope of the S3 Access Grant."
  value = {
    type       = aws_s3control_access_grant.this.s3_prefix_type == local.prefix_type["OBJECT"] ? "OBJECT" : "PREFIX"
    sub_prefix = one(aws_s3control_access_grant.this.access_grants_location_configuration[*].s3_sub_prefix)
    path       = aws_s3control_access_grant.this.grant_scope
  }
}

output "grantee" {
  description = "The grantee to which the access is given."
  value = {
    type       = aws_s3control_access_grant.this.grantee[0].grantee_type
    identifier = aws_s3control_access_grant.this.grantee[0].grantee_identifier
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
