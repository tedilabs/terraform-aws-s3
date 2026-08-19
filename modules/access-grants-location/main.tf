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

data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {
  region = var.region
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  partition  = data.aws_partition.this.partition
  region     = data.aws_region.this.region
}


###################################################
# S3 Access Grants Location
###################################################

locals {
  # The location scope is one of the default location `s3://`, a bucket
  # `s3://bucket/`, or a bucket with a prefix `s3://bucket/prefix`.
  scope_path   = trimprefix(var.location_scope, "s3://")
  scope_parts  = split("/", local.scope_path)
  scope_bucket = local.scope_parts[0]
  scope_prefix = join("/", slice(local.scope_parts, 1, length(local.scope_parts)))

  default_scope_enabled = local.scope_bucket == ""

  iam_role = (var.default_iam_role.enabled
    ? one(aws_iam_role.this[*].arn)
    : var.iam_role
  )
}

resource "aws_s3control_access_grants_location" "this" {
  region = var.region

  location_scope = var.location_scope
  iam_role_arn   = local.iam_role

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    precondition {
      condition     = var.default_iam_role.enabled || var.iam_role != null
      error_message = "`iam_role` is required when the value of `default_iam_role.enabled` is `false`."
    }
  }
}
