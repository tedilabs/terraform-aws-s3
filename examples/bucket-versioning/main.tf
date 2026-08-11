provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Bucket
###################################################

resource "random_string" "this" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

locals {
  bucket_name = random_string.this.id
}

module "bucket" {
  source = "../../modules/bucket"
  # source  = "tedilabs/s3/aws//modules/bucket"
  # version = "~> 0.1.0"

  name          = local.bucket_name
  force_destroy = true

  versioning = {
    status = "ENABLED"
    mfa_deletion = {
      enabled = false
      device  = null
    }
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}
