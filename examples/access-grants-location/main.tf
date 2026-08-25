provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Bucket
###################################################

data "aws_caller_identity" "this" {}

locals {
  account_id  = data.aws_caller_identity.this.account_id
  bucket_name = "access-grants-location-example-${local.account_id}"
}

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
# S3 Access Grants Instance
###################################################

module "instance" {
  source = "../../modules/access-grants-instance"
  # source  = "tedilabs/s3/aws//modules/access-grants-instance"
  # version = "~> 0.1.0"

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}


###################################################
# S3 Access Grants Location
###################################################

module "location" {
  source = "../../modules/access-grants-location"
  # source  = "tedilabs/s3/aws//modules/access-grants-location"
  # version = "~> 0.1.0"

  scope = "s3://${module.bucket.name}"

  tags = {
    "project" = "terraform-aws-s3-examples"
  }

  depends_on = [
    module.instance,
  ]
}
