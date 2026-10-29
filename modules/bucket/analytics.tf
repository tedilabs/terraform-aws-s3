###################################################
# Storage Class Analysis for S3 Bucket
###################################################

locals {
  analytics_rules = {
    for rule in var.analytics.rules :
    rule.name => rule
  }
}

resource "aws_s3_bucket_analytics_configuration" "this" {
  for_each = local.analytics_rules

  region = var.region

  bucket = aws_s3_bucket.this.bucket
  name   = each.key

  dynamic "filter" {
    for_each = each.value.filter != null ? (try(length(each.value.filter.prefix), 0) > 0 || length(each.value.filter.tags) > 0 ? [each.value.filter] : []) : []

    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }

  dynamic "storage_class_analysis" {
    for_each = each.value.data_export.enabled ? [each.value.data_export] : []
    iterator = export

    content {
      data_export {
        output_schema_version = export.value.schema_version

        destination {
          s3_bucket_destination {
            bucket_arn        = provider::aws::arn_build("aws", "s3", "", "", export.value.s3_bucket.name)
            bucket_account_id = export.value.s3_bucket.expected_bucket_owner
            prefix            = export.value.s3_bucket.key_prefix
            format            = export.value.format
          }
        }
      }
    }
  }
}
