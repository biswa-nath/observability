output "s3_bucket_name" {
  description = "Name of the S3 bucket for observability data"
  value       = aws_s3_bucket.observability.bucket
}

output "observability_role_arn" {
  description = "IAM role ARN for observability components"
  value       = aws_iam_role.observability.arn
}
