output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3_access_point.this.region
}

output "name" {
  description = "The name of the S3 Access Point."
  value       = aws_s3_access_point.this.name
}

output "id" {
  description = "The ID of the S3 Access Point."
  value       = aws_s3_access_point.this.id
}

output "arn" {
  description = "The ARN of the S3 Access Point."
  value       = aws_s3_access_point.this.arn
}

output "alias" {
  description = "The alias of the S3 Access Point."
  value       = aws_s3_access_point.this.alias
}

output "bucket" {
  description = "The bucket associated with this Access Point."
  value = {
    name       = aws_s3_access_point.this.bucket
    account_id = aws_s3_access_point.this.bucket_account_id
  }
}

output "network_origin" {
  description = "Indicates whether this access point allows access from the public Internet. Values are `VPC` (the access point doesn't allow access from the public Internet) and `INTERNET` (the access point allows access from the public Internet, subject to the access point and bucket access policies)."
  value       = upper(aws_s3_access_point.this.network_origin)
}

output "has_public_access_policy" {
  description = "Whether this access point currently has a policy that allows public access."
  value = (var.policy != null && var.policy != ""
    ? one(aws_s3control_access_point_policy.this[*].has_public_access_policy)
    : aws_s3_access_point.this.has_public_access_policy
  )
}

output "vpc_id" {
  description = "The VPC ID is to be only allowed connections to this access point if `network_origin` is `VPC`."
  value       = one(aws_s3_access_point.this.vpc_configuration[*].vpc_id)
}

output "domain_name" {
  description = "The DNS domain name of the S3 Access Point in the format `{name-account_id}.s3-accesspoint.{region}.amazonaws.com`. Note: S3 access points only support secure access by HTTPS. HTTP isn't supported."
  value       = aws_s3_access_point.this.domain_name
}

output "endpoints" {
  description = "The VPC endpoints for the S3 Access Point."
  value       = aws_s3_access_point.this.endpoints
}

output "block_public_access" {
  description = "The configuration for the S3 bucket access control."
  value = {
    block_public_acls_enabled       = one(aws_s3_access_point.this.public_access_block_configuration[*]).block_public_acls
    ignore_public_acls_enabled      = one(aws_s3_access_point.this.public_access_block_configuration[*]).ignore_public_acls
    block_public_policy_enabled     = one(aws_s3_access_point.this.public_access_block_configuration[*]).block_public_policy
    restrict_public_buckets_enabled = one(aws_s3_access_point.this.public_access_block_configuration[*]).restrict_public_buckets
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
