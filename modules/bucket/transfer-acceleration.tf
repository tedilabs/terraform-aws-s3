###################################################
# Transfer Acceleration for S3 Bucket
###################################################

resource "aws_s3_bucket_accelerate_configuration" "this" {
  region = var.region

  bucket = aws_s3_bucket.this.bucket
  status = var.transfer_acceleration_enabled ? "Enabled" : "Suspended"
}
