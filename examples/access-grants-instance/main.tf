provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Access Grants Instance
###################################################

module "instance" {
  source = "../../modules/access-grants-instance"
  # source  = "tedilabs/s3/aws//modules/access-grants-instance"
  # version = "~> 0.1.0"

  ## RAM Shares
  shares = [
    # {
    #   name       = "example"
    #   principals = ["123456789012"]
    # },
  ]

  tags = {
    "project" = "terraform-aws-s3-examples"
  }
}
