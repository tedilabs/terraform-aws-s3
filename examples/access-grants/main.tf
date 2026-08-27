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

data "aws_iam_policy_document" "grantee_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetDataAccess"]
    resources = ["*"]
  }
}

module "grantee_role" {
  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.0"

  name = "access-grants-example-grantee"

  trusted_iam_entity_policies = [
    {
      iam_entities = ["arn:aws:iam::${local.account_id}:root"]
    }
  ]

  inline_policies = {
    "s3-access-grants" = data.aws_iam_policy_document.grantee_access.json
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}


###################################################
# S3 Access Grant
###################################################

module "grant" {
  source = "../../modules/access-grants-grant"
  # source  = "tedilabs/s3/aws//modules/access-grants-grant"
  # version = "~> 0.1.0"

  name     = "example-analytics-read"
  location = module.location.id

  permission = "READ"
  scope = {
    type       = "PREFIX"
    sub_prefix = "analytics/*"
  }
  grantee = {
    type = "IAM"
    id   = module.grantee_role.arn
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}
