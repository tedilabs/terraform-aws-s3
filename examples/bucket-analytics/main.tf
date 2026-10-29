provider "aws" {
  region = "us-east-1"
}

resource "random_string" "this" {
  length  = 20
  special = false
  numeric = false
  upper   = false
}

data "aws_caller_identity" "this" {}

locals {
  bucket_name  = "analytics-${random_string.this.id}"
  reports_name = "analytics-reports-${random_string.this.id}"
}

# Analytics exports require a destination in the same region with a policy
# granting Amazon S3 permission to write reports.
module "reports" {
  source = "../../modules/bucket"

  name          = local.reports_name
  force_destroy = true

  analytics = {
    is_target_bucket = true
    allowed_source_buckets = [{
      name                  = local.bucket_name
      key_prefix            = "analytics/"
      expected_bucket_owner = data.aws_caller_identity.this.account_id
    }]
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}

module "bucket" {
  source = "../../modules/bucket"

  name          = local.bucket_name
  force_destroy = true

  analytics = {
    rules = [
      { name = "entire-bucket" },
      {
        name = "documents"
        filter = {
          prefix = "documents/"
          tags   = { classification = "archive" }
        }
        data_export = {
          enabled = true
          s3_bucket = {
            name                  = local.reports_name
            key_prefix            = "analytics/"
            expected_bucket_owner = data.aws_caller_identity.this.account_id
          }
        }
      },
    ]
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }

  depends_on = [module.reports]
}
