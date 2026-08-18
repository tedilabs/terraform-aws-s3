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
# S3 Access Grant
###################################################

resource "aws_s3control_access_grant" "this" {
  region = var.region

  access_grants_location_id = var.location_id
  permission                = var.permission
  s3_prefix_type            = var.s3_prefix_type

  dynamic "access_grants_location_configuration" {
    for_each = var.s3_sub_prefix != null ? [var.s3_sub_prefix] : []

    content {
      s3_sub_prefix = access_grants_location_configuration.value
    }
  }

  grantee {
    grantee_type       = var.grantee.type
    grantee_identifier = var.grantee.identifier
  }

  tags = merge(
    { "Name" = local.metadata.name },
    local.module_tags,
    var.tags,
  )
}
