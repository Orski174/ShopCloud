variable "env" {
  type        = string
  description = "Environment (dev or prod)"
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "alb_arn_suffix" {
  type        = string
  description = "ARN suffix of the ALB for CloudWatch metrics"
}

variable "target_group_arn_suffixes" {
  type        = map(string)
  description = "Map of service names to target group ARN suffixes"
}

variable "admin_target_group_arn_suffix" {
  type        = string
  description = "ARN suffix of the admin target group"
}

variable "services" {
  type        = list(string)
  description = "List of service names"
  default     = ["auth", "catalog", "cart", "checkout", "admin", "invoice"]
}

variable "rds_cluster_id" {
  type        = string
  description = "RDS cluster identifier"
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name"
}

variable "sqs_queue_name" {
  type        = string
  description = "SQS queue name"
  default     = ""
}

variable "sqs_dlq_name" {
  type        = string
  description = "SQS dead-letter queue name"
  default     = ""
}

variable "email_endpoint" {
  type        = string
  description = "Email address for SNS alerts"
  default     = "alerts@shopcloud.local"
}
