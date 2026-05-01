variable "env" {
  type        = string
  description = "Environment: dev or prod"
}

variable "billing_mode" {
  type        = string
  default     = "PAY_PER_REQUEST"
  description = "DynamoDB billing mode"
}
