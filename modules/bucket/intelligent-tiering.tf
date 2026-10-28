###################################################
# Intelligent-Tiering for S3 Bucket
###################################################

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = {
    for rule in var.intelligent_tiering_rules :
    rule.name => rule
  }

  region = var.region

  bucket = aws_s3_bucket.this.bucket
  name   = each.key
  status = each.value.enabled ? "Enabled" : "Disabled"

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []

    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }

  dynamic "tiering" {
    for_each = each.value.tierings

    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }
}
