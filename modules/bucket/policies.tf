data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
}

## Enforce TLS (HTTPS Only)
data "aws_iam_policy_document" "tls_required" {
  statement {
    sid = "RequireTlsForRequest"

    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.name}",
      "arn:aws:s3:::${var.name}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "access_logging" {
  statement {
    sid = "S3ServerAccessLogsPolicy"

    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.name}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = length(var.logging.allowed_source_buckets) > 0 ? ["go"] : []

      content {
        test     = "StringLike"
        variable = "aws:SourceArn"
        values = [
          for bucket in var.logging.allowed_source_buckets :
          "arn:aws:s3:::${bucket}"
        ]
      }
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}


data "aws_iam_policy_document" "analytics_export" {
  dynamic "statement" {
    for_each = var.analytics.is_target_bucket ? var.analytics.allowed_source_buckets : []

    content {
      sid       = "S3AnalyticsExport${statement.key}"
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["arn:aws:s3:::${var.name}/${statement.value.key_prefix != null ? statement.value.key_prefix : ""}*"]

      principals {
        type        = "Service"
        identifiers = ["s3.amazonaws.com"]
      }

      condition {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = ["arn:aws:s3:::${statement.value.name}"]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [coalesce(statement.value.expected_bucket_owner, local.account_id)]
      }
      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }
    }
  }
}
