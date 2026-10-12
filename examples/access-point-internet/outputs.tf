output "bucket" {
  description = "The outputs of the S3 bucket module."
  value       = module.bucket
}

output "access_point" {
  description = "The outputs of the S3 access point module."
  value       = module.access_point
}
