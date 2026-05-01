output "public_alb_dns_name" {
  value       = aws_lb.public.dns_name
  description = "DNS name of the public ALB"
}

output "public_alb_arn" {
  value       = aws_lb.public.arn
  description = "ARN of the public ALB"
}

output "public_alb_arn_suffix" {
  value       = aws_lb.public.arn_suffix
  description = "ARN suffix of the public ALB for CloudWatch"
}

output "public_alb_sg_id" {
  value       = aws_security_group.alb_public.id
  description = "Security group ID for public ALB"
}

output "internal_alb_dns_name" {
  value       = aws_lb.internal.dns_name
  description = "DNS name of the internal ALB"
}

output "internal_alb_arn" {
  value       = aws_lb.internal.arn
  description = "ARN of the internal ALB"
}

output "target_group_arns" {
  value       = { for k, v in aws_lb_target_group.services : k => v.arn }
  description = "Map of service names to target group ARNs"
}

output "target_group_arn_suffixes" {
  value       = { for k, v in aws_lb_target_group.services : k => v.arn_suffix }
  description = "Map of service names to target group ARN suffixes"
}

output "admin_target_group_arn" {
  value       = aws_lb_target_group.admin.arn
  description = "ARN of the admin target group"
}

output "admin_target_group_arn_suffix" {
  value       = aws_lb_target_group.admin.arn_suffix
  description = "ARN suffix of the admin target group"
}
