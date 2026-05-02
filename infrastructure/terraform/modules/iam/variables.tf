variable "env" {
  type        = string
  description = "Environment: dev or prod"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

variable "github_org" {
  type        = string
  description = "GitHub org/user"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "ARN of DynamoDB carts table"
}

variable "s3_invoices_bucket_arn" {
  type        = string
  description = "ARN of S3 invoices bucket"
}

variable "s3_images_bucket_arn" {
  type        = string
  description = "ARN of S3 images bucket"
}

variable "frontend_bucket_arn" {
  type        = string
  description = "ARN of S3 frontend hosting bucket"
}

variable "frontend_cloudfront_distribution_arn" {
  type        = string
  description = "ARN of CloudFront distribution serving the frontend"
}

variable "sqs_invoice_queue_arn" {
  type        = string
  description = "ARN of SQS invoice queue"
}

variable "rds_secret_arn" {
  type        = string
  description = "ARN of RDS secret in Secrets Manager"
}
