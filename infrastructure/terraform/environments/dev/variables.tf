variable "aws_region" {
  description = "AWS region for the dev environment."
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID."
  type        = string
}

variable "env" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "services" {
  description = "ShopCloud microservices."
  type        = list(string)
  default = [
    "auth",
    "catalog",
    "cart",
    "checkout",
    "admin",
    "invoice"
  ]
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "azs" {
  description = "Availability zones."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "github_org" {
  description = "GitHub organization."
  type        = string
  default     = "Orski174"
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
  default     = "EECE503Q"
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "shopcloud"
}

variable "db_username" {
  description = "Database username."
  type        = string
  default     = "shopcloud"
}

variable "email_endpoint" {
  description = "Email endpoint for SNS alerts."
  type        = string
  default     = "alerts@shopcloud.local"
}