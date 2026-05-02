variable "env" {
  type        = string
  description = "Environment: dev or prod"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "Existing VPC ID to reuse (optional, for free tier). If null, create new VPC."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ)"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}
