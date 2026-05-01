output "table_name" {
  value       = aws_dynamodb_table.carts.name
  description = "DynamoDB table name"
}

output "table_arn" {
  value       = aws_dynamodb_table.carts.arn
  description = "DynamoDB table ARN"
}
