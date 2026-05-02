output "cluster_endpoint" {
  value       = split(":", aws_db_instance.main.endpoint)[0]
  description = "RDS instance endpoint address (hostname only)"
}

output "reader_endpoint" {
  value       = split(":", aws_db_instance.main.endpoint)[0]
  description = "RDS instance endpoint address (hostname only, same as writer for single-instance)"
}

output "db_secret_arn" {
  value       = aws_secretsmanager_secret.db.arn
  description = "ARN of the RDS credentials secret"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "RDS security group ID"
}

output "db_name" {
  value       = aws_db_instance.main.db_name
  description = "Database name"
}

output "db_port" {
  value       = 5432
  description = "Database port"
}
