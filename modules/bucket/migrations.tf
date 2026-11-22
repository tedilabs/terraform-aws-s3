# 2026-11-23
moved {
  from = aws_s3_bucket_policy.this
  to   = aws_s3_bucket_policy.this[0]
}
