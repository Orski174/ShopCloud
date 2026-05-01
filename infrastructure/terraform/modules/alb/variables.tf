variable "env" {
  type        = string
  description = "Environment (dev or prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from vpc module"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for public ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for internal ALB"
}

variable "services" {
  type = map(object({
    port              = number
    health_check_path = string
  }))
  description = "Map of service configurations"
  default = {
    auth     = { port = 3001, health_check_path = "/health" }
    catalog  = { port = 3002, health_check_path = "/health" }
    cart     = { port = 3003, health_check_path = "/health" }
    checkout = { port = 3004, health_check_path = "/health" }
    invoice  = { port = 3006, health_check_path = "/health" }
  }
}

variable "enable_ssl" {
  type        = bool
  description = "Enable SSL/TLS on ALB"
  default     = false
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS (required if enable_ssl is true)"
  default     = ""
}
