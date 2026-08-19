locals {
  metadata = {
    package = "terraform-aws-s3"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = local.region
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {
  region = var.region
}
data "aws_ssoadmin_instances" "default" {
  count = var.iam_identity_center.enabled && var.iam_identity_center.instance == null ? 1 : 0

  region = var.region
}


locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.region
}


###################################################
# S3 Access Grants Instance
###################################################

resource "aws_s3control_access_grants_instance" "this" {
  region = var.region

  account_id = local.account_id
  identity_center_arn = (var.iam_identity_center.enabled
    ? (var.iam_identity_center.instance != null
      ? var.iam_identity_center.instance
      : one(data.aws_ssoadmin_instances.default[*].arns[0])

    )
    : null
  )

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Resource Policy for S3 Access Grants Instance
###################################################

resource "aws_s3control_access_grants_instance_resource_policy" "this" {
  count = var.policy != null ? 1 : 0

  region = var.region

  account_id = aws_s3control_access_grants_instance.this.account_id
  policy     = var.policy
}
