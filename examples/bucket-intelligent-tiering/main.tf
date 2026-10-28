provider "aws" {
  region = "us-east-1"
}

resource "random_string" "this" {
  length  = 20
  special = false
  numeric = false
  upper   = false
}

module "bucket" {
  source = "../../modules/bucket"

  name          = "intelligent-tiering-${random_string.this.id}"
  force_destroy = true

  # Archive access tiers only apply to objects in INTELLIGENT_TIERING.
  lifecycle_rules = [
    {
      id          = "intelligent-tiering"
      transitions = [{ days = 0, storage_class = "INTELLIGENT_TIERING" }]
    },
  ]

  intelligent_tiering_rules = [
    {
      name = "entire-bucket"
      tierings = [
        { access_tier = "ARCHIVE_ACCESS", days = 90 },
        { access_tier = "DEEP_ARCHIVE_ACCESS", days = 180 },
      ]
    },
    {
      name    = "filtered"
      enabled = false
      filter = {
        prefix = "documents/"
        tags   = { archive = "true" }
      }
      tierings = [{ access_tier = "DEEP_ARCHIVE_ACCESS", days = 365 }]
    },
  ]

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}
