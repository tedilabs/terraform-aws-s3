locals {
  default_iam_role_name = coalesce(
    var.default_iam_role.name,
    "s3-access-grants-${local.metadata.name}",
  )

  read_enabled  = contains(["READ", "READWRITE"], var.default_iam_role.permission)
  write_enabled = contains(["WRITE", "READWRITE"], var.default_iam_role.permission)

  bucket_arns = [
    provider::aws::arn_build(local.partition, "s3", "", "", local.default_scope_enabled
      ? "*"
      : local.scope_bucket
    )
  ]
  object_arns = [
    provider::aws::arn_build(local.partition, "s3", "", "", local.default_scope_enabled
      ? "*/*"
      : "${local.scope_bucket}/${local.scope_prefix}*"
    )
  ]
}


###################################################
# IAM Role for S3 Access Grants Location
###################################################

# INFO: The `tedilabs/account/aws//modules/iam-role` module is not used because
# the trust policy of the location IAM role requires the `sts:SetContext`
# action which is needed to vend credentials for the IAM Identity Center
# directory users and groups.
resource "aws_iam_role" "this" {
  count = var.default_iam_role.enabled ? 1 : 0

  name                 = local.default_iam_role_name
  path                 = var.default_iam_role.path
  description          = var.default_iam_role.description
  max_session_duration = var.default_iam_role.max_session_duration
  permissions_boundary = var.default_iam_role.permissions_boundary

  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  force_detach_policies = true

  tags = merge(
    {
      "Name" = local.default_iam_role_name
    },
    local.module_tags,
    var.tags,
  )
}

data "aws_iam_policy_document" "assume_role" {
  count = var.default_iam_role.enabled ? 1 : 0

  statement {
    sid    = "TrustedAccessGrantsService"
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
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.instance]
    }
  }
}


###################################################
# Policies of IAM Role for S3 Access Grants Location
###################################################

resource "aws_iam_role_policy" "this" {
  count = var.default_iam_role.enabled ? 1 : 0

  role   = aws_iam_role.this[0].id
  name   = "s3-access-grants-location"
  policy = data.aws_iam_policy_document.this[0].json
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.default_iam_role.enabled ? var.default_iam_role.inline_policies : {}

  role   = aws_iam_role.this[0].id
  name   = each.key
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = var.default_iam_role.enabled ? var.default_iam_role.policies : toset([])

  role       = aws_iam_role.this[0].id
  policy_arn = each.key
}

# INFO: The permissions of this policy are the ceiling of all grants of the S3
# Access Grants location. A grant can only narrow down the permissions.
data "aws_iam_policy_document" "this" {
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

      condition {
        test     = "StringEquals"
        variable = "aws:ResourceAccount"
        values   = [local.account_id]
      }

      condition {
        test     = "ArnEquals"
        variable = "s3:AccessGrantsInstanceArn"
        values   = [var.instance]
      }

      dynamic "condition" {
        for_each = local.scope_prefix != "" ? ["go"] : []

        content {
          test     = "StringLike"
          variable = "s3:prefix"
          values   = ["${local.scope_prefix}*"]
        }
      }
    }
  }

  dynamic "statement" {
    for_each = local.read_enabled ? ["go"] : []

    content {
      sid    = "ObjectLevelReadPermissions"
      effect = "Allow"
      actions = concat(
        [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListMultipartUploadParts",
        ],
        (var.default_iam_role.object_acl_enabled
          ? [
            "s3:GetObjectAcl",
            "s3:GetObjectVersionAcl",
          ]
          : []
        ),
      )
      resources = local.object_arns

      condition {
        test     = "StringEquals"
        variable = "aws:ResourceAccount"
        values   = [local.account_id]
      }

      condition {
        test     = "ArnEquals"
        variable = "s3:AccessGrantsInstanceArn"
        values   = [var.instance]
      }
    }
  }

  dynamic "statement" {
    for_each = local.write_enabled ? ["go"] : []

    content {
      sid    = "ObjectLevelWritePermissions"
      effect = "Allow"
      actions = concat(
        [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:AbortMultipartUpload",
        ],
        (var.default_iam_role.object_acl_enabled
          ? [
            "s3:PutObjectAcl",
            "s3:PutObjectVersionAcl",
          ]
          : []
        ),
      )
      resources = local.object_arns

      condition {
        test     = "StringEquals"
        variable = "aws:ResourceAccount"
        values   = [local.account_id]
      }

      condition {
        test     = "ArnEquals"
        variable = "s3:AccessGrantsInstanceArn"
        values   = [var.instance]
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
