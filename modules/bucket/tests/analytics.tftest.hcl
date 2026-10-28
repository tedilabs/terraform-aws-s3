mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  name   = "s3-configuration-test"
  region = "us-east-1"
  resource_group = {
    enabled = false
  }
  telemetry = {
    enabled = false
  }
}

run "defaults" {
  command = plan

  assert {
    condition     = length(aws_s3_bucket_analytics_configuration.this) == 0 && length(output.analytics_configurations) == 0
    error_message = "Existing callers must not create Analytics configurations."
  }
}

run "configurations" {
  command = plan

  variables {
    analytics_configurations = [
      { name = "entire-bucket" },
      {
        name = "filtered-export"
        filter = {
          prefix = "documents/"
          tags   = { classification = "archive" }
        }
        data_export = {
          bucket_arn        = "arn:aws:s3:::analytics-destination"
          bucket_account_id = "210987654321"
          prefix            = "reports/"
        }
      },
      { name = "tags-only", filter = { tags = { archive = "true" } } },
      {
        name   = "prefix-export"
        filter = { prefix = "logs/" }
        data_export = {
          bucket_arn            = "arn:aws:s3:::analytics-destination"
          format                = "CSV"
          output_schema_version = "V_1"
        }
      },
    ]
  }

  assert {
    condition = (
      length(aws_s3_bucket_analytics_configuration.this) == 4 &&
      aws_s3_bucket_analytics_configuration.this["entire-bucket"].bucket == var.name &&
      aws_s3_bucket_analytics_configuration.this["entire-bucket"].region == var.region &&
      length(aws_s3_bucket_analytics_configuration.this["entire-bucket"].filter) == 0 &&
      length(aws_s3_bucket_analytics_configuration.this["entire-bucket"].storage_class_analysis) == 0 &&
      output.analytics_configurations["entire-bucket"].data_export == null
    )
    error_message = "Analysis without filters or exports must remain supported."
  }
  assert {
    condition = (
      output.analytics_configurations["filtered-export"].filter.prefix == "documents/" &&
      output.analytics_configurations["filtered-export"].filter.tags["classification"] == "archive" &&
      output.analytics_configurations["filtered-export"].data_export.bucket_arn == "arn:aws:s3:::analytics-destination" &&
      output.analytics_configurations["filtered-export"].data_export.bucket_account_id == "210987654321" &&
      output.analytics_configurations["filtered-export"].data_export.prefix == "reports/" &&
      output.analytics_configurations["filtered-export"].data_export.format == "CSV" &&
      output.analytics_configurations["filtered-export"].data_export.output_schema_version == "V_1"
    )
    error_message = "Filters, cross-account destination, prefix, and export defaults must reach the provider."
  }
  assert {
    condition = (
      output.analytics_configurations["tags-only"].filter.tags["archive"] == "true" &&
      output.analytics_configurations["prefix-export"].filter.prefix == "logs/" &&
      output.analytics_configurations["prefix-export"].data_export.format == "CSV"
    )
    error_message = "Tag-only and prefix-only filters must work with optional export fields omitted."
  }
}

run "reject_duplicate_names" {
  command = plan

  variables {
    analytics_configurations = [{ name = "duplicate" }, { name = "duplicate" }]
  }

  expect_failures = [var.analytics_configurations]
}

run "reject_empty_name" {
  command = plan

  variables {
    analytics_configurations = [{ name = " " }]
  }

  expect_failures = [var.analytics_configurations]
}

run "reject_unsupported_format" {
  command = plan

  variables {
    analytics_configurations = [{ name = "invalid", data_export = { bucket_arn = "arn:aws:s3:::analytics-destination", format = "JSON" } }]
  }

  expect_failures = [var.analytics_configurations]
}

run "reject_unsupported_schema" {
  command = plan

  variables {
    analytics_configurations = [{ name = "invalid", data_export = { bucket_arn = "arn:aws:s3:::analytics-destination", output_schema_version = "V_2" } }]
  }

  expect_failures = [var.analytics_configurations]
}
