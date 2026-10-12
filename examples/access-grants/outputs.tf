output "instance" {
  description = "The outputs of the S3 Access Grants instance module."
  value       = module.instance
}

output "location" {
  description = "The outputs of the S3 Access Grants location module."
  value       = module.location
}

output "grant" {
  description = "The outputs of the S3 Access Grant module."
  value       = module.grant
}
