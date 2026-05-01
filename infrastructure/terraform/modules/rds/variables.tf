variable "env" {
  type        = string
  description = "Environment: dev or prod"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for DB cluster"
}

variable "db_name" {
  type        = string
  default     = "shopcloud"
  description = "Database name"
}

variable "db_username" {
  type        = string
  default     = "shopcloud"
  description = "Master username"
}

variable "allowed_security_group_id" {
  type        = string
  description = "Security group ID allowed to connect to RDS"
}

variable "min_capacity" {
  type        = number
  default     = 0.5
  description = "Minimum Aurora ACUs"
}

variable "max_capacity" {
  type        = number
  default     = 4
  description = "Maximum Aurora ACUs"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip final snapshot on deletion"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Days to retain backups"
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection"
}
