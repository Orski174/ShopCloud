output "invoices_bucket_name" {
  value       = aws_s3_bucket.invoices.id
  description = "Invoices S3 bucket name"
}

output "invoices_bucket_arn" {
  value       = aws_s3_bucket.invoices.arn
  description = "Invoices S3 bucket ARN"
}

output "images_bucket_name" {
  value       = aws_s3_bucket.images.id
  description = "Images S3 bucket name"
}

output "images_bucket_arn" {
  value       = aws_s3_bucket.images.arn
  description = "Images S3 bucket ARN"
}

output "images_bucket_domain_name" {
  value       = aws_s3_bucket.images.bucket_regional_domain_name
  description = "Images bucket regional domain name for CloudFront"
}
