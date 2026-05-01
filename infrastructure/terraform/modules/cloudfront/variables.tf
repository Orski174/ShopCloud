variable "env" {
  type        = string
  description = "Environment: dev or prod"
}

variable "alb_dns_name" {
  type        = string
  description = "Public ALB DNS name"
}

variable "images_bucket_domain" {
  type        = string
  description = "S3 images bucket regional domain"
}

variable "images_bucket_arn" {
  type        = string
  description = "S3 images bucket ARN"
}

variable "waf_acl_arn" {
  type        = string
  description = "WAF ACL ARN"
}
