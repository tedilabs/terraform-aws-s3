output "bucket" {
  description = "The outputs of the S3 bucket module."
  value       = module.bucket
}

output "log_bucket" {
  description = "The outputs of the S3 access log bucket module."
  value       = module.log_bucket
}
