output "cluster_endpoint" {
  value       = aws_rds_cluster.main.endpoint
  description = "RDS cluster writer endpoint"
}

output "reader_endpoint" {
  value       = aws_rds_cluster.main.reader_endpoint
  description = "RDS cluster reader endpoint"
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
  value       = aws_rds_cluster.main.database_name
  description = "Database name"
}

output "db_port" {
  value       = 5432
  description = "Database port"
}
