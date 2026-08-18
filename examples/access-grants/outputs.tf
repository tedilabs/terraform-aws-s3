output "bucket" {
  description = "The S3 bucket registered with S3 Access Grants."
  value       = module.bucket
}

output "access_grants_instance" {
  description = "The regional S3 Access Grants instance."
  value       = module.access_grants_instance
}

output "access_grants_location" {
  description = "The registered S3 Access Grants location and its IAM role."
  value       = module.access_grants_location
}

output "access_grant" {
  description = "The READ grant for the example IAM role."
  value       = module.access_grant
}
