variable "aws_region" {
  description = "AWS region for the dev environment."
  type        = string
  default     = "us-east-1"
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