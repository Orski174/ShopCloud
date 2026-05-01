output "distribution_id" {
  value       = aws_cloudfront_distribution.main.id
  description = "CloudFront distribution ID"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.main.domain_name
  description = "CloudFront distribution domain name"
}

output "distribution_arn" {
  value       = aws_cloudfront_distribution.main.arn
  description = "CloudFront distribution ARN"
}
