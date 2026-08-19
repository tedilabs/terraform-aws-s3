locals {
  ram_share_name_prefix = join(".", [
    "s3",
    "access-grants",
    "instance",
    replace(local.metadata.name, "/[^a-zA-Z0-9_\\.-]/", "-"),
  ])
}


###################################################
# Resource Sharing by RAM (Resource Access Manager)
###################################################

module "share" {
  source  = "tedilabs/organization/aws//modules/ram-share"
  version = "~> 0.8.1"

  for_each = {
    for share in var.shares :
    share.name => share
  }

  region = aws_s3control_access_grants_instance.this.region

  name = "${local.ram_share_name_prefix}.${each.key}"

  resources = {
    (local.metadata.name) = aws_s3control_access_grants_instance.this.access_grants_instance_arn
  }
  permissions = each.value.permissions

  external_principals_allowed = each.value.external_principals_allowed
  principals                  = each.value.principals

  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
    each.value.tags,
  )
}
