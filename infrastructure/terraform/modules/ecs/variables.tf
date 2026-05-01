variable "env" {
  type        = string
  description = "Environment (dev or prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for ECS tasks"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID of the public ALB"
}

variable "ecs_exec_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role"
}

variable "task_role_arns" {
  type        = map(string)
  description = "Map of service names to task role ARNs"
}

variable "target_group_arns" {
  type        = map(string)
  description = "Map of service names to target group ARNs"
}

variable "admin_target_group_arn" {
  type        = string
  description = "ARN of the admin service target group"
}

variable "db_secret_arn" {
  type        = string
  description = "ARN of the RDS secret in Secrets Manager"
}

variable "db_host" {
  type        = string
  description = "RDS cluster endpoint"
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "shopcloud"
}

variable "db_username" {
  type        = string
  description = "Database username"
  default     = "shopcloud"
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for carts"
}

variable "s3_invoices_bucket" {
  type        = string
  description = "S3 bucket name for invoices"
}

variable "s3_images_bucket" {
  type        = string
  description = "S3 bucket name for images"
}

variable "sqs_invoice_queue_url" {
  type        = string
  description = "SQS queue URL for invoices"
  default     = ""
}

variable "services" {
  type        = list(string)
  description = "List of service names"
  default     = ["auth", "catalog", "cart", "checkout", "admin", "invoice"]
}

variable "cpu" {
  type        = map(number)
  description = "CPU units per service (256 = 0.25 vCPU)"
  default = {
    auth     = 256
    catalog  = 512
    cart     = 256
    checkout = 512
    admin    = 256
    invoice  = 256
  }
}

variable "memory" {
  type        = map(number)
  description = "Memory in MB per service"
  default = {
    auth     = 512
    catalog  = 1024
    cart     = 512
    checkout = 1024
    admin    = 512
    invoice  = 512
  }
}

variable "desired_count" {
  type        = map(number)
  description = "Desired task count per service"
  default = {
    auth     = 2
    catalog  = 2
    cart     = 2
    checkout = 2
    admin    = 1
    invoice  = 1
  }
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}
