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
data "aws_partition" "this" {}

locals {
  bucket_name  = "analytics-${random_string.this.id}"
  reports_name = "analytics-reports-${random_string.this.id}"
  bucket_arn   = "arn:${data.aws_partition.this.partition}:s3:::${local.bucket_name}"
  reports_arn  = "arn:${data.aws_partition.this.partition}:s3:::${local.reports_name}"
}

# Analytics exports require a destination in the same region with a policy
# granting Amazon S3 permission to write reports.
module "reports" {
  source = "../../modules/bucket"

  name          = local.reports_name
  force_destroy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowAnalyticsReports"
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "${local.reports_arn}/analytics/*"
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = local.bucket_arn
        }
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.this.account_id
          "s3:x-amz-acl"      = "bucket-owner-full-control"
        }
      }
    }]
  })

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}

module "bucket" {
  source = "../../modules/bucket"

  name          = local.bucket_name
  force_destroy = true

  analytics_configurations = [
    { name = "entire-bucket" },
    {
      name = "documents"
      filter = {
        prefix = "documents/"
        tags   = { classification = "archive" }
      }
      data_export = {
        bucket_arn        = module.reports.arn
        bucket_account_id = data.aws_caller_identity.this.account_id
        prefix            = "analytics/"
      }
    },
  ]

  tags = {
    "project" = "terraform-aws-s3-examples"
  }

  depends_on = [module.reports]
}
