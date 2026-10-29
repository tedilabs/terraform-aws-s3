# Evaluate the real provider's policy documents without AWS API calls.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "testing"
  secret_key                  = "testing"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

override_data {
  target = data.aws_caller_identity.this
  values = { account_id = "123456789012" }
}

override_data {
  target = data.aws_canonical_user_id.this
  values = { id = "testing" }
}

variables {
  name           = "s3-configuration-test"
  region         = "us-east-1"
  resource_group = { enabled = false }
  telemetry      = { enabled = false }
}

run "defaults" {
  command = plan

  assert {
    condition = (
      length(aws_s3_bucket_analytics_configuration.this) == 0 &&
      length(output.analytics.rules) == 0 &&
      length(jsondecode(data.aws_iam_policy_document.this.json).Statement) == 1
    )
    error_message = "Existing callers must not create Analytics rules or export permissions."
  }
}

run "filters_and_exports" {
  command = plan

  variables {
    analytics = {
      rules = [
        { name = "entire-bucket" },
        { name = "empty-filter", filter = {} },
        { name = "empty-values", filter = { prefix = "", tags = {} } },
        { name = "null-values", filter = { prefix = null, tags = null } },
        { name = "tags-only", filter = { tags = { archive = "true" } } },
        { name = "multiple-tags", filter = { tags = { archive = "true", team = "platform" } } },
        {
          name = "filtered-export"
          filter = {
            prefix = "documents/"
            tags   = { classification = "archive" }
          }
          data_export = {
            enabled = true
            s3_bucket = {
              name                  = "analytics-destination"
              expected_bucket_owner = "210987654321"
              key_prefix            = "reports/"
            }
          }
        },
        {
          name   = "prefix-export"
          filter = { prefix = "logs/" }
          data_export = {
            enabled   = true
            s3_bucket = { name = "analytics-destination" }
          }
        },
        {
          name = "disabled-export"
          data_export = {
            s3_bucket = { name = "analytics-destination" }
          }
        },
      ]
    }
  }

  assert {
    condition = alltrue([
      for name in ["entire-bucket", "empty-filter", "empty-values", "null-values"] :
      length(aws_s3_bucket_analytics_configuration.this[name].filter) == 0 && output.analytics.rules[name].filter == null
    ])
    error_message = "Absent, empty and null filter values must omit the provider filter block."
  }
  assert {
    condition = (
      output.analytics.rules["tags-only"].filter.tags["archive"] == "true" &&
      length(output.analytics.rules["multiple-tags"].filter.tags) == 2 &&
      output.analytics.rules["prefix-export"].filter.prefix == "logs/" &&
      output.analytics.rules["filtered-export"].filter.prefix == "documents/" &&
      output.analytics.rules["filtered-export"].filter.tags["classification"] == "archive"
    )
    error_message = "Prefix, tag and combined filters must reach the provider."
  }
  assert {
    condition = (
      aws_s3_bucket_analytics_configuration.this["filtered-export"].storage_class_analysis[0].data_export[0].destination[0].s3_bucket_destination[0].bucket_arn == "arn:aws:s3:::analytics-destination" &&
      aws_s3_bucket_analytics_configuration.this["filtered-export"].storage_class_analysis[0].data_export[0].output_schema_version == "V_1" &&
      aws_s3_bucket_analytics_configuration.this["filtered-export"].storage_class_analysis[0].data_export[0].destination[0].s3_bucket_destination[0].format == "CSV" &&
      output.analytics.rules["filtered-export"].data_export.enabled &&
      output.analytics.rules["filtered-export"].data_export.s3_bucket.name == "analytics-destination" &&
      output.analytics.rules["filtered-export"].data_export.s3_bucket.expected_bucket_owner == "210987654321" &&
      output.analytics.rules["filtered-export"].data_export.s3_bucket.key_prefix == "reports/"
    )
    error_message = "Enabled exports must map the destination name, owner, prefix, format and schema to the provider."
  }
  assert {
    condition = (
      !output.analytics.rules["entire-bucket"].data_export.enabled &&
      !output.analytics.rules["disabled-export"].data_export.enabled &&
      length(aws_s3_bucket_analytics_configuration.this["disabled-export"].storage_class_analysis) == 0 &&
      output.analytics.rules["disabled-export"].data_export.s3_bucket == null
    )
    error_message = "Specifying a destination alone must not enable exports."
  }
}

run "target_policies" {
  command = plan

  variables {
    analytics = {
      is_target_bucket = true
      allowed_source_buckets = [
        { name = "source-a", key_prefix = "reports/a/" },
        { name = "source-b", key_prefix = "reports/b/", expected_bucket_owner = "210987654321" },
        { name = "source-c" },
      ]
    }
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid       = "CustomRead"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::123456789012:root" }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::s3-configuration-test/*"
      }]
    })
  }

  assert {
    condition = (
      length(jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement) == 3 &&
      jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement[0].Resource == "arn:aws:s3:::s3-configuration-test/reports/a/*" &&
      jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement[0].Condition.ArnEquals["aws:SourceArn"] == "arn:aws:s3:::source-a" &&
      jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement[0].Condition.StringEquals["aws:SourceAccount"] == "123456789012" &&
      jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement[1].Resource == "arn:aws:s3:::s3-configuration-test/reports/b/*" &&
      jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement[1].Condition.ArnEquals["aws:SourceArn"] == "arn:aws:s3:::source-b" &&
      jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement[1].Condition.StringEquals["aws:SourceAccount"] == "210987654321" &&
      jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement[2].Resource == "arn:aws:s3:::s3-configuration-test/*"
    )
    error_message = "Each source must retain its own account and destination prefix, with current-account and whole-bucket defaults."
  }
  assert {
    condition = alltrue([
      for statement in jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement :
      statement.Action == "s3:PutObject" &&
      statement.Principal.Service == "s3.amazonaws.com" &&
      statement.Condition.StringEquals["s3:x-amz-acl"] == "bucket-owner-full-control"
    ])
    error_message = "Export permissions must allow only S3 service report writes with bucket-owner-full-control."
  }
  assert {
    condition = (
      length(jsondecode(aws_s3_bucket_policy.this.policy).Statement) == 5 &&
      contains([for statement in jsondecode(aws_s3_bucket_policy.this.policy).Statement : statement.Sid], "CustomRead") &&
      contains([for statement in jsondecode(aws_s3_bucket_policy.this.policy).Statement : statement.Sid], "RequireTlsForRequest") &&
      output.analytics.is_target_bucket &&
      length(output.analytics.allowed_source_buckets) == 3 &&
      length(output.analytics.rules) == 0 &&
      length(aws_s3_bucket_analytics_configuration.this) == 0
    )
    error_message = "Report-only destinations must create no analysis resources and merge permissions with TLS and user policies."
  }
}

run "reject_duplicate_names" {
  command = plan
  variables {
    analytics = { rules = [{ name = "duplicate" }, { name = "duplicate" }] }
  }
  expect_failures = [var.analytics]
}

run "reject_empty_name" {
  command = plan
  variables {
    analytics = { rules = [{ name = " " }] }
  }
  expect_failures = [var.analytics]
}

run "reject_unsupported_format" {
  command = plan
  variables {
    analytics = { rules = [{ name = "invalid", data_export = { format = "JSON" } }] }
  }
  expect_failures = [var.analytics]
}

run "reject_unsupported_schema" {
  command = plan
  variables {
    analytics = { rules = [{ name = "invalid", data_export = { schema_version = "V_2" } }] }
  }
  expect_failures = [var.analytics]
}

run "reject_missing_destination" {
  command = plan
  variables {
    analytics = { rules = [{ name = "invalid", data_export = { enabled = true } }] }
  }
  expect_failures = [var.analytics]
}

run "reject_empty_destination" {
  command = plan
  variables {
    analytics = { rules = [{ name = "invalid", data_export = { enabled = true, s3_bucket = { name = " " } } }] }
  }
  expect_failures = [var.analytics]
}

run "reject_empty_sources" {
  command = plan
  variables {
    analytics = { is_target_bucket = true }
  }
  expect_failures = [var.analytics]
}

run "reject_wildcard_source" {
  command = plan
  variables {
    analytics = { is_target_bucket = true, allowed_source_buckets = [{ name = "*" }] }
  }
  expect_failures = [var.analytics]
}

run "reject_empty_source_name" {
  command = plan
  variables {
    analytics = { is_target_bucket = true, allowed_source_buckets = [{ name = " " }] }
  }
  expect_failures = [var.analytics]
}

run "inactive_target" {
  command = plan
  variables {
    analytics = { allowed_source_buckets = [{ name = "ignored-source" }] }
  }
  assert {
    condition = (
      !output.analytics.is_target_bucket &&
      length(aws_s3_bucket_analytics_configuration.this) == 0 &&
      length(jsondecode(data.aws_iam_policy_document.this.json).Statement) == 1
    )
    error_message = "A source list alone must not enable incoming permissions or create analysis rules."
  }
}

run "analyze_and_receive" {
  command = plan
  variables {
    analytics = {
      rules                  = [{ name = "entire-bucket" }, { name = "logs", filter = { prefix = "logs/" } }]
      is_target_bucket       = true
      allowed_source_buckets = [{ name = "source-a" }]
    }
  }
  assert {
    condition = (
      length(aws_s3_bucket_analytics_configuration.this) == 2 &&
      length(jsondecode(data.aws_iam_policy_document.analytics_export.json).Statement) == 1 &&
      length(jsondecode(data.aws_iam_policy_document.this.json).Statement) == 2
    )
    error_message = "Incoming permissions must be generated once per source, independently of the number of analysis rules."
  }
}
