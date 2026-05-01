output "ecs_exec_role_arn" {
  value       = aws_iam_role.ecs_exec.arn
  description = "ECS task execution role ARN"
}

output "auth_task_role_arn" {
  value       = aws_iam_role.auth_task.arn
  description = "Auth service task role ARN"
}

output "catalog_task_role_arn" {
  value       = aws_iam_role.catalog_task.arn
  description = "Catalog service task role ARN"
}

output "cart_task_role_arn" {
  value       = aws_iam_role.cart_task.arn
  description = "Cart service task role ARN"
}

output "checkout_task_role_arn" {
  value       = aws_iam_role.checkout_task.arn
  description = "Checkout service task role ARN"
}

output "admin_task_role_arn" {
  value       = aws_iam_role.admin_task.arn
  description = "Admin service task role ARN"
}

output "invoice_task_role_arn" {
  value       = aws_iam_role.invoice_task.arn
  description = "Invoice service task role ARN"
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "GitHub Actions OIDC deploy role ARN"
}
