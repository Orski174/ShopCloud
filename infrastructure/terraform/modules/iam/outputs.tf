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

output "eks_cluster_role_arn" {
  value       = aws_iam_role.eks_cluster.arn
  description = "EKS cluster service role ARN"
}

output "eks_node_role_arn" {
  value       = aws_iam_role.eks_node.arn
  description = "EKS node group role ARN"
}

output "eks_node_instance_profile" {
  value       = aws_iam_instance_profile.eks_node.name
  description = "EKS node instance profile name"
}

output "eks_service_account_role_arn" {
  value       = aws_iam_role.eks_service_account.arn
  description = "EKS service account role ARN (for IRSA)"
}
