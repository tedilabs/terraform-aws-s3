locals {
  instance_arn = "arn:${local.partition}:s3:${local.region}:${local.account_id}:access-grants/default"

  scope       = trimprefix(var.location_scope, "s3://")
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
}


###################################################
# IAM Role for S3 Access Grants Location
###################################################

data "aws_iam_policy_document" "trust" {
  count = var.default_iam_role.enabled ? 1 : 0

  statement {
    sid    = "AllowAccessGrantsToAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:SetContext",
    ]

    principals {
      type        = "Service"
      identifiers = ["access-grants.s3.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:s3:*:${local.account_id}:access-grants/default"]
    }
  }
}

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

resource "aws_iam_role" "this" {
  count = var.default_iam_role.enabled ? 1 : 0

  name        = coalesce(var.default_iam_role.name, "s3-access-grants-${local.metadata.name}-location")
  path        = var.default_iam_role.path
  description = var.default_iam_role.description

  assume_role_policy    = data.aws_iam_policy_document.trust[0].json
  permissions_boundary  = var.default_iam_role.permissions_boundary
  force_detach_policies = true

  tags = merge(
    {
      "Name" = coalesce(var.default_iam_role.name, "s3-access-grants-${local.metadata.name}-location")
    },
    local.module_tags,
    var.tags,
  )
}

resource "aws_iam_role_policy" "access" {
  count = var.default_iam_role.enabled ? 1 : 0

  role   = aws_iam_role.this[0].id
  name   = "s3-access-grants-location"
  policy = data.aws_iam_policy_document.access[0].json
}

resource "aws_iam_role_policy" "custom" {
  for_each = var.default_iam_role.enabled ? var.default_iam_role.inline_policies : {}

  role   = aws_iam_role.this[0].id
  name   = each.key
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.default_iam_role.enabled ? toset(var.default_iam_role.policies) : toset([])

  role       = aws_iam_role.this[0].id
  policy_arn = each.value
}
