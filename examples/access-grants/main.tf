provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}

resource "random_string" "this" {
  length  = 24
  special = false
  numeric = true
  upper   = false
}

locals {
  name = "access-grants-${random_string.this.id}"
  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}


###################################################
# S3 Bucket
###################################################

module "bucket" {
  source = "../../modules/bucket"

  name          = local.name
  force_destroy = true
  tags          = local.tags
}


###################################################
# S3 Access Grants Instance
###################################################

module "access_grants_instance" {
  source = "../../modules/access-grants-instance"

  name = "example"
  tags = local.tags
}


###################################################
# S3 Access Grants Location
###################################################

data "aws_iam_policy_document" "location" {
  statement {
    sid       = "ListAnalyticsPrefix"
    actions   = ["s3:ListBucket"]
    resources = [module.bucket.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["analytics/*"]
    }
  }

  statement {
    sid       = "ReadAnalyticsObjects"
    actions   = ["s3:GetObject"]
    resources = ["${module.bucket.arn}/analytics/*"]
  }
}

module "access_grants_location" {
  source = "../../modules/access-grants-location"

  name                       = "analytics"
  access_grants_instance_arn = module.access_grants_instance.arn
  location_scope             = "s3://${module.bucket.name}/"

  iam_role = {
    inline_policies = {
      "analytics-read" = data.aws_iam_policy_document.location.json
    }
  }

  tags = local.tags
}


###################################################
# IAM Grantee
###################################################

data "aws_iam_policy_document" "consumer_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "consumer" {
  name               = "${local.name}-consumer"
  assume_role_policy = data.aws_iam_policy_document.consumer_assume_role.json
  tags               = local.tags
}


###################################################
# S3 Access Grant
###################################################

module "access_grant" {
  source = "../../modules/access-grant"

  name        = "analytics-read"
  location_id = module.access_grants_location.id
  permission  = "READ"
  grantee = {
    type       = "IAM"
    identifier = aws_iam_role.consumer.arn
  }
  s3_sub_prefix = "analytics/*"

  tags = local.tags
}
