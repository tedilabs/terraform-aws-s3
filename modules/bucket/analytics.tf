###################################################
# Storage Class Analysis for S3 Bucket
###################################################

resource "aws_s3_bucket_analytics_configuration" "this" {
  for_each = {
    for configuration in var.analytics_configurations :
    configuration.name => configuration
  }

  region = var.region

  bucket = aws_s3_bucket.this.bucket
  name   = each.key

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []

    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }

  dynamic "storage_class_analysis" {
    for_each = each.value.data_export != null ? [each.value.data_export] : []
    iterator = export

    content {
      data_export {
        output_schema_version = export.value.output_schema_version

        destination {
          s3_bucket_destination {
            bucket_arn        = export.value.bucket_arn
            bucket_account_id = export.value.bucket_account_id
            prefix            = export.value.prefix
            format            = export.value.format
          }
        }
      }
    }
  }
}
