output "buckets" {
  description = "The outputs of the source and target S3 bucket modules."
  value = {
    source = module.source_bucket
    target = module.target_bucket
  }
}
