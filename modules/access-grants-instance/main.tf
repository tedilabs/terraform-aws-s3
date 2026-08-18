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
# S3 Access Grants Instance
###################################################

resource "aws_s3control_access_grants_instance" "this" {
  region = var.region

  identity_center_arn = var.identity_center_arn

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

  depends_on = [aws_s3control_access_grants_instance.this]

  region = var.region
  policy = var.policy
}
