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
      length(aws_s3_bucket_policy.this) == 1 &&
      length(jsondecode(aws_s3_bucket_policy.this[0].policy).Statement) == 1
    )
    error_message = "The default TLS statement must keep the bucket policy."
  }
}

run "no_statements" {
  command = plan

  variables {
    tls_required = false
  }

  assert {
    condition     = length(aws_s3_bucket_policy.this) == 0
    error_message = "A bucket policy without any statement must not be created."
  }
}

run "custom_policy_only" {
  command = plan

  variables {
    tls_required = false
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
      length(aws_s3_bucket_policy.this) == 1 &&
      jsondecode(aws_s3_bucket_policy.this[0].policy).Statement[0].Sid == "CustomRead"
    )
    error_message = "A user policy alone must create the bucket policy."
  }
}

run "access_logging_target_only" {
  command = plan

  variables {
    tls_required = false
    logging = {
      is_target_bucket = true
    }
  }

  assert {
    condition = (
      length(aws_s3_bucket_policy.this) == 1 &&
      jsondecode(aws_s3_bucket_policy.this[0].policy).Statement[0].Sid == "S3ServerAccessLogsPolicy"
    )
    error_message = "The access logging statement alone must create the bucket policy."
  }
}
