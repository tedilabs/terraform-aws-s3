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

data "aws_region" "this" {
  region = var.region
}

locals {
  region = data.aws_region.this.region
}


###################################################
# S3 Access Grants Instance
###################################################

# INFO: Not supported attributes
# - `account_id`
resource "aws_s3control_access_grants_instance" "this" {
  region = var.region

  identity_center_arn = (var.iam_identity_center.enabled
    ? var.iam_identity_center.instance
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

# INFO: The resource policy is a singleton of the account and the region, and
# doesn't reference the S3 Access Grants instance. Use `depends_on` to create
# the S3 Access Grants instance first.
resource "aws_s3control_access_grants_instance_resource_policy" "this" {
  count = var.policy != null ? 1 : 0

  region = var.region

  policy = var.policy

  depends_on = [aws_s3control_access_grants_instance.this]
}
