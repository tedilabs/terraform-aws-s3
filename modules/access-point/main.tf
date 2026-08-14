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


###################################################
# S3 Access Point
###################################################

resource "aws_s3_access_point" "this" {
  region = var.region

  account_id = var.account_id
  name       = var.name

  bucket            = var.bucket.name
  bucket_account_id = var.bucket.account_id

  dynamic "vpc_configuration" {
    for_each = var.network_origin == "VPC" ? [var.vpc_id] : []

    content {
      vpc_id = vpc_configuration.value
    }
  }

  public_access_block_configuration {
    block_public_acls       = (var.block_public_access.enabled || var.block_public_access.block_public_acls_enabled)
    ignore_public_acls      = (var.block_public_access.enabled || var.block_public_access.ignore_public_acls_enabled)
    block_public_policy     = (var.block_public_access.enabled || var.block_public_access.block_public_policy_enabled)
    restrict_public_buckets = (var.block_public_access.enabled || var.block_public_access.restrict_public_buckets_enabled)
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    precondition {
      condition = anytrue([
        var.network_origin != "VPC",
        var.network_origin == "VPC" && var.vpc_id != null,
      ])
      error_message = "`vpc_id` is required when the value of `network_origin` is `VPC`."
    }

    ignore_changes = [
      policy,
    ]
  }
}


###################################################
# Policy for S3 Access Point
###################################################

resource "aws_s3control_access_point_policy" "this" {
  count = var.policy != null && var.policy != "" ? 1 : 0

  region = var.region

  access_point_arn = aws_s3_access_point.this.arn
  policy           = var.policy
}
