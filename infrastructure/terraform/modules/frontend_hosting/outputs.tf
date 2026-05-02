output "bucket_name" {
  description = "Frontend S3 bucket name."
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "Frontend S3 bucket ARN."
  value       = aws_s3_bucket.frontend.arn
}

output "cloudfront_domain_name" {
  description = "Frontend CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_distribution_id" {
  description = "Frontend CloudFront distribution ID."
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_arn" {
  description = "Frontend CloudFront distribution ARN."
  value       = aws_cloudfront_distribution.frontend.arn
}
