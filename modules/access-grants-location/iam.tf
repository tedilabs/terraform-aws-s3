locals {
  instance_arn = "arn:${local.partition}:s3:${local.region}:${local.account_id}:access-grants/default"

  scope       = trimprefix(var.scope, "s3://")
  scope_parts = split("/", local.scope)
  bucket      = local.scope_parts[0]
  key_prefix  = trimsuffix(join("/", slice(local.scope_parts, 1, length(local.scope_parts))), "*")

  default_scope_enabled = local.bucket == ""
  bucket_arns = (local.default_scope_enabled
    ? ["arn:${local.partition}:s3:::*"]
    : ["arn:${local.partition}:s3:::${local.bucket}"]
  )
  object_arns = (local.default_scope_enabled
    ? ["arn:${local.partition}:s3:::*"]
    : ["arn:${local.partition}:s3:::${local.bucket}/${local.key_prefix}*"]
  )

  read_enabled  = contains(["READ", "READWRITE"], var.default_iam_role.permission)
  write_enabled = contains(["WRITE", "READWRITE"], var.default_iam_role.permission)

  default_iam_role_name = coalesce(
    var.default_iam_role.name,
    join("-", [
      "s3-access-grants",
      (local.default_scope_enabled
        ? "default"
        : trimsuffix(replace(local.scope, "/[^a-zA-Z0-9_.-]/", "-"), "-")
      ),
      "location",
    ]),
  )
}


###################################################
# IAM Role for S3 Access Grants Location
###################################################

data "aws_iam_policy_document" "access" {
  count = var.default_iam_role.enabled ? 1 : 0

  dynamic "statement" {
    for_each = local.read_enabled ? ["go"] : []

    content {
      sid    = "BucketLevelReadPermissions"
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:ListBucketVersions",
        "s3:ListBucketMultipartUploads",
      ]
      resources = local.bucket_arns

      dynamic "condition" {
        for_each = local.key_prefix != "" ? ["go"] : []

        content {
          test     = "StringLike"
          variable = "s3:prefix"
          values   = ["${local.key_prefix}*"]
        }
      }
      condition {
        test     = "StringEquals"
        variable = "aws:ResourceAccount"
        values   = [local.account_id]
      }
      condition {
        test     = "ArnEquals"
        variable = "s3:AccessGrantsInstanceArn"
        values   = [local.instance_arn]
      }
    }
  }

  dynamic "statement" {
    for_each = local.read_enabled ? ["go"] : []

    content {
      sid    = "ObjectLevelReadPermissions"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetObjectAcl",
        "s3:GetObjectVersionAcl",
        "s3:ListMultipartUploadParts",
      ]
      resources = local.object_arns

      condition {
        test     = "StringEquals"
        variable = "aws:ResourceAccount"
        values   = [local.account_id]
      }
      condition {
        test     = "ArnEquals"
        variable = "s3:AccessGrantsInstanceArn"
        values   = [local.instance_arn]
      }
    }
  }

  dynamic "statement" {
    for_each = local.write_enabled ? ["go"] : []

    content {
      sid    = "ObjectLevelWritePermissions"
      effect = "Allow"
      actions = [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersionAcl",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion",
        "s3:AbortMultipartUpload",
      ]
      resources = local.object_arns

      condition {
        test     = "StringEquals"
        variable = "aws:ResourceAccount"
        values   = [local.account_id]
      }
      condition {
        test     = "ArnEquals"
        variable = "s3:AccessGrantsInstanceArn"
        values   = [local.instance_arn]
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.default_iam_role.kms_keys) > 0 ? ["go"] : []

    content {
      sid    = "KMSPermissions"
      effect = "Allow"
      actions = concat(
        local.read_enabled ? ["kms:Decrypt"] : [],
        local.write_enabled ? ["kms:GenerateDataKey"] : [],
      )
      resources = var.default_iam_role.kms_keys

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["s3.${local.region}.amazonaws.com"]
      }
    }
  }
}

module "default_iam_role" {
  count = var.default_iam_role.enabled ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.11"

  name        = local.default_iam_role_name
  path        = var.default_iam_role.path
  description = var.default_iam_role.description

  trusted_service_policies = [
    {
      services = ["access-grants.s3.amazonaws.com"]
      conditions = [
        {
          key       = "aws:SourceAccount"
          condition = "StringEquals"
          values    = [local.account_id]
        },
        {
          key       = "aws:SourceArn"
          condition = "ArnLike"
          values    = ["arn:${local.partition}:s3:*:${local.account_id}:access-grants/default"]
        },
      ]
    }
  ]
  trusted_session_context = {
    enabled = true
  }

  policies = var.default_iam_role.policies
  inline_policies = merge({
    "s3-access-grants-location" = data.aws_iam_policy_document.access[0].json
  }, var.default_iam_role.inline_policies)

  permissions_boundary = var.default_iam_role.permissions_boundary

  force_detach_policies = true
  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
