output "buckets" {
  description = "The outputs of the S3 bucket modules, keyed by encryption type."
  value = {
    "AES256"  = module.bucket
    "AWS_KMS" = module.bucket_kms
  }
}

output "kms_key" {
  description = "The outputs of the KMS key module."
  value       = module.kms_key
}
