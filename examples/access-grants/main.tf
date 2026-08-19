provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Bucket
###################################################

data "aws_caller_identity" "this" {}

locals {
  account_id  = data.aws_caller_identity.this.account_id
  bucket_name = "access-grants-example-${local.account_id}"
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


###################################################
# IAM Role for Grantee
###################################################

data "aws_iam_policy_document" "grantee_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.account_id]
    }
  }
}

data "aws_iam_policy_document" "grantee_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetDataAccess"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "grantee" {
  name               = "access-grants-example-grantee"
  assume_role_policy = data.aws_iam_policy_document.grantee_trust.json

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}

resource "aws_iam_role_policy" "grantee" {
  role   = aws_iam_role.grantee.id
  name   = "s3-access-grants"
  policy = data.aws_iam_policy_document.grantee_access.json
}


###################################################
# S3 Access Grant
###################################################

module "grant" {
  source = "../../modules/access-grant"
  # source  = "tedilabs/s3/aws//modules/access-grant"
  # version = "~> 0.1.0"

  name        = "example-analytics-read"
  location_id = module.location.id

  permission    = "READ"
  s3_sub_prefix = "analytics/*"
  grantee = {
    type       = "IAM"
    identifier = aws_iam_role.grantee.arn
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}
