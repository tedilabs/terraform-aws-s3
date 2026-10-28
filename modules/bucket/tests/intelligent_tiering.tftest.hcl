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
    condition     = length(aws_s3_bucket_intelligent_tiering_configuration.this) == 0 && length(output.intelligent_tiering_rules) == 0
    error_message = "Existing callers must not create Intelligent-Tiering configurations."
  }
}

run "configurations" {
  command = plan

  variables {
    intelligent_tiering_rules = [
      {
        name = "entire-bucket"
        tierings = [
          { access_tier = "ARCHIVE_ACCESS", days = 90 },
          { access_tier = "DEEP_ARCHIVE_ACCESS", days = 730 },
        ]
      },
      {
        name    = "filtered"
        enabled = false
        filter = {
          prefix = "documents/"
          tags   = { classification = "archive" }
        }
        tierings = [{ access_tier = "DEEP_ARCHIVE_ACCESS", days = 180 }]
      },
      {
        name     = "tags-only"
        filter   = { tags = { archive = "true" } }
        tierings = [{ access_tier = "ARCHIVE_ACCESS", days = 730 }]
      },
      {
        name     = "prefix-only"
        filter   = { prefix = "logs/" }
        tierings = [{ access_tier = "ARCHIVE_ACCESS", days = 90 }]
      },
    ]
  }

  assert {
    condition = (
      length(aws_s3_bucket_intelligent_tiering_configuration.this) == 4 &&
      aws_s3_bucket_intelligent_tiering_configuration.this["entire-bucket"].bucket == var.name &&
      aws_s3_bucket_intelligent_tiering_configuration.this["entire-bucket"].region == var.region &&
      aws_s3_bucket_intelligent_tiering_configuration.this["entire-bucket"].status == "Enabled" &&
      length(aws_s3_bucket_intelligent_tiering_configuration.this["entire-bucket"].filter) == 0 &&
      length(aws_s3_bucket_intelligent_tiering_configuration.this["entire-bucket"].tiering) == 2
    )
    error_message = "Unfiltered configurations must target this bucket and preserve both archive tiers."
  }
  assert {
    condition = (
      !output.intelligent_tiering_rules["filtered"].enabled &&
      output.intelligent_tiering_rules["filtered"].filter.prefix == "documents/" &&
      output.intelligent_tiering_rules["filtered"].filter.tags["classification"] == "archive" &&
      one(output.intelligent_tiering_rules["filtered"].tierings).days == 180 &&
      output.intelligent_tiering_rules["tags-only"].filter.tags["archive"] == "true" &&
      output.intelligent_tiering_rules["prefix-only"].filter.prefix == "logs/"
    )
    error_message = "Disabled status, tier days, and prefix/tag filters must be preserved."
  }
}

run "reject_empty_tiers" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = "invalid", tierings = [] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}

run "reject_duplicate_tiers" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = "invalid", tierings = [{ access_tier = "ARCHIVE_ACCESS", days = 90 }, { access_tier = "ARCHIVE_ACCESS", days = 100 }] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}

run "reject_unsupported_tier" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = "invalid", tierings = [{ access_tier = "STANDARD", days = 90 }] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}

run "reject_archive_too_early" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = "invalid", tierings = [{ access_tier = "ARCHIVE_ACCESS", days = 89 }] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}

run "reject_deep_archive_too_early" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = "invalid", tierings = [{ access_tier = "DEEP_ARCHIVE_ACCESS", days = 179 }] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}

run "reject_too_late" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = "invalid", tierings = [{ access_tier = "ARCHIVE_ACCESS", days = 731 }] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}

run "reject_fractional_days" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = "invalid", tierings = [{ access_tier = "ARCHIVE_ACCESS", days = 90.5 }] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}

run "reject_duplicate_names" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = "duplicate", tierings = [{ access_tier = "ARCHIVE_ACCESS", days = 90 }] }, { name = "duplicate", tierings = [{ access_tier = "DEEP_ARCHIVE_ACCESS", days = 180 }] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}

run "reject_empty_name" {
  command = plan

  variables {
    intelligent_tiering_rules = [{ name = " ", tierings = [{ access_tier = "ARCHIVE_ACCESS", days = 90 }] }]
  }

  expect_failures = [var.intelligent_tiering_rules]
}
