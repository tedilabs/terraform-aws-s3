locals {
  metadata = {
    package = "terraform-aws-s3"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

data "aws_partition" "this" {}

data "aws_caller_identity" "this" {}

data "aws_region" "this" {
  region = var.region
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  partition  = data.aws_partition.this.partition
  region     = data.aws_region.this.region

  iam_role = (var.default_iam_role.enabled
    ? one(aws_iam_role.this[*].arn)
    : var.iam_role
  )
}


###################################################
# S3 Access Grants Location
###################################################

# INFO: Not supported attributes
# - `account_id`
resource "aws_s3control_access_grants_location" "this" {
  region = var.region

  iam_role_arn   = local.iam_role
  location_scope = var.location_scope

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
