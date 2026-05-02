variable "env" {
  description = "Environment name."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID, used to make the frontend bucket name globally unique."
  type        = string
}
