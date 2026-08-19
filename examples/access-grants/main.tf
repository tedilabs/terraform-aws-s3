provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Bucket for the Data Lake
###################################################

data "aws_caller_identity" "this" {}

locals {
  bucket_name = "access-grants-example-${local.account_id}"
  account_id  = data.aws_caller_identity.this.account_id
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

## The S3 Access Grants instance is a singleton of the region of the account.
## Associate an IAM Identity Center instance with `iam_identity_center` to
## create grants for the corporate directory users and groups.
module "access_grants_instance" {
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

## The default IAM role of the location is scoped down to the location scope,
## and is the ceiling of all grants of the location.
module "access_grants_location" {
  source = "../../modules/access-grants-location"
  # source  = "tedilabs/s3/aws//modules/access-grants-location"
  # version = "~> 0.1.0"

  name           = "example-marketing"
  instance       = module.access_grants_instance.arn
  location_scope = "s3://${module.bucket.name}/marketing/"

  default_iam_role = {
    permission = "READWRITE"
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}


###################################################
# S3 Access Grant
###################################################

## The grantee calls `s3:GetDataAccess` to get the temporary credentials which
## are limited to the grant scope and the permission of this grant.
module "grantee_role" {
  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.0"

  name = "s3-access-grants-example-consumer"

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
    resources = [module.access_grants_instance.arn]
  }
}

module "access_grant" {
  source = "../../modules/access-grant"
  # source  = "tedilabs/s3/aws//modules/access-grant"
  # version = "~> 0.1.0"

  name       = "example-marketing-read"
  location   = module.access_grants_location.id
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
