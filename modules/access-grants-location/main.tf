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
  iam_role_arn = var.iam_role.enabled ? aws_iam_role.this[0].arn : var.iam_role_arn
}

data "aws_caller_identity" "this" {}


###################################################
# IAM Role for S3 Access Grants Location
###################################################

data "aws_iam_policy_document" "assume_role" {
  count = var.iam_role.enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:SetContext",
      "sts:SetSourceIdentity",
    ]

    principals {
      type        = "Service"
      identifiers = ["access-grants.s3.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.access_grants_instance_arn]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.iam_role.enabled ? 1 : 0

  name                 = coalesce(var.iam_role.name, "s3-access-grants-${var.name}")
  path                 = var.iam_role.path
  description          = var.iam_role.description
  permissions_boundary = var.iam_role.permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.assume_role[0].json

  tags = merge(
    { "Name" = coalesce(var.iam_role.name, "s3-access-grants-${var.name}") },
    local.module_tags,
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.iam_role.enabled ? var.iam_role.policies : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "this" {
  for_each = var.iam_role.enabled ? var.iam_role.inline_policies : {}

  role   = aws_iam_role.this[0].name
  name   = each.key
  policy = each.value
}


###################################################
# S3 Access Grants Location
###################################################

resource "aws_s3control_access_grants_location" "this" {
  region = var.region

  iam_role_arn   = local.iam_role_arn
  location_scope = var.location_scope

  tags = merge(
    { "Name" = local.metadata.name },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    precondition {
      condition     = var.iam_role.enabled || var.iam_role_arn != null
      error_message = "`iam_role_arn` is required when `iam_role.enabled` is `false`."
    }
  }
}
