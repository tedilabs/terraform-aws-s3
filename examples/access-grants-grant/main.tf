provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Bucket
###################################################

data "aws_caller_identity" "this" {}

locals {
  account_id  = data.aws_caller_identity.this.account_id
  bucket_name = "access-grants-grant-example-${local.account_id}"
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

  scope = "s3://${module.bucket.name}/marketing/"

  default_iam_role = {
    permission = "READ"
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }

  depends_on = [
    module.instance,
  ]
}


###################################################
# IAM Role for the Grantee
###################################################

## The grantee needs the `s3:GetDataAccess` permission of its own IAM policy to
## request the temporary credentials of the granted S3 data.
module "grantee_role" {
  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.11"

  name = "s3-access-grants-grant-example"

  trusted_iam_entity_policies = [
    {
      iam_entities = [local.account_id]
    },
  ]
  inline_policies = {
    "s3-access-grants" = data.aws_iam_policy_document.grantee.json
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}

data "aws_iam_policy_document" "grantee" {
  statement {
    sid    = "S3AccessGrants"
    effect = "Allow"
    actions = [
      "s3:GetDataAccess",
      "s3:GetAccessGrantsInstanceForPrefix",
    ]
    resources = [module.instance.arn]
  }
}


###################################################
# S3 Access Grant
###################################################

module "grant" {
  source = "../../modules/access-grants-grant"
  # source  = "tedilabs/s3/aws//modules/access-grants-grant"
  # version = "~> 0.1.0"

  name       = "marketing-campaigns-read"
  location   = module.location.id
  permission = "READ"

  grantee = {
    type       = "IAM"
    identifier = module.grantee_role.arn
  }
  scope = {
    sub_prefix = "campaigns/*"
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}
