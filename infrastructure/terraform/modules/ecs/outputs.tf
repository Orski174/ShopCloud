output "cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "ECS cluster name"
}

output "cluster_arn" {
  value       = aws_ecs_cluster.main.arn
  description = "ECS cluster ARN"
}

output "ecs_sg_id" {
  value       = aws_security_group.ecs_tasks.id
  description = "ECS tasks security group ID"
}

output "task_definition_arns" {
  value       = { for k, v in aws_ecs_task_definition.services : k => v.arn }
  description = "Map of service names to task definition ARNs"
}

output "service_arns" {
  value       = { for k, v in aws_ecs_service.services : k => v.id }
  description = "Map of service names to service ARNs"
}
