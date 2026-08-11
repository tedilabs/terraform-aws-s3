provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "random_string" "this" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

locals {
  bucket_name       = random_string.this.id
  access_point_name = "access-point-test-internet"

  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.region
}


###################################################
# S3 Bucket
###################################################

module "bucket" {
  source = "../../modules/bucket"
  # source  = "tedilabs/s3/aws//modules/bucket"
  # version = "~> 0.1.0"

  name          = local.bucket_name
  force_destroy = true

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}


###################################################
# S3 Access Point
###################################################

module "access_point" {
  source = "../../modules/access-point"
  # source  = "tedilabs/s3/aws//modules/access-point"
  # version = "~> 0.1.0"

  name = local.access_point_name
  bucket = {
    name = module.bucket.name
  }

  policy = null
  block_public_access = {
    enabled = true
  }
}
