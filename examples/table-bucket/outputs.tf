output "table_bucket" {
  description = "The outputs of the S3 table bucket module."
  value       = module.table_bucket
}

output "table" {
  description = "The outputs of the S3 table module."
  value       = module.table
}
