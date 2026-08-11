provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Bucket
###################################################

resource "random_string" "this" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

locals {
  bucket_name = random_string.this.id
}

module "bucket" {
  source = "../../modules/bucket"
  # source  = "tedilabs/s3/aws//modules/bucket"
  # version = "~> 0.1.0"

  name          = local.bucket_name
  force_destroy = true

  objects = {
    files = [
      {
        key     = "config/app.json"
        content = jsonencode({ env = "example" })
      },
      {
        key           = "docs/index.html"
        source        = "${path.module}/files/index.html"
        cache_control = "max-age=300"
      },
    ]
    directories = [
      {
        path             = "${path.module}/files"
        key_prefix       = "static/"
        exclude_patterns = [".*"]
      },
    ]
  }

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}
