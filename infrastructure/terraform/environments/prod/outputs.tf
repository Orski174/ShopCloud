output "ecr_repository_urls" {
  description = "ECR repository URLs for ShopCloud services."
  value       = local.ecr_repository_urls
}

output "ecr_repository_names" {
  description = "ECR repository names for ShopCloud services."
  value       = local.ecr_repository_names
}

output "vpc_id" {
  description = "VPC ID (using existing default VPC)"
  value       = local.vpc_id
}

output "public_alb_dns_name" {
  description = "Public ALB DNS name"
  value       = module.alb.public_alb_dns_name
}

output "internal_alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = module.alb.internal_alb_dns_name
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = module.frontend_hosting.bucket_name
}

output "frontend_cloudfront_domain_name" {
  description = "Frontend CloudFront distribution domain name"
  value       = module.frontend_hosting.cloudfront_domain_name
}

output "frontend_cloudfront_distribution_id" {
  description = "Frontend CloudFront distribution ID"
  value       = module.frontend_hosting.cloudfront_distribution_id
}

output "rds_endpoint" {
  description = "RDS cluster endpoint"
  value       = module.rds.cluster_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "s3_invoices_bucket" {
  description = "S3 invoices bucket name"
  value       = module.s3.invoices_bucket_name
}

output "s3_images_bucket" {
  description = "S3 images bucket name"
  value       = module.s3.images_bucket_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "github_actions_role_arn" {
  description = "GitHub Actions OIDC deploy role ARN"
  value       = module.iam.github_actions_role_arn
}

output "sqs_queue_url" {
  description = "SQS invoice queue URL"
  value       = aws_sqs_queue.invoice_queue.url
}

output "github_actions_role_arn" {
  description = "GitHub Actions OIDC role ARN for prod deployments"
  value       = module.iam.github_actions_role_arn
}
