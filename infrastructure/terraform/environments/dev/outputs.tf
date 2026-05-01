output "ecr_repository_urls" {
  description = "ECR repository URLs for ShopCloud services."
  value       = module.ecr.repository_urls
}

output "ecr_repository_names" {
  description = "ECR repository names for ShopCloud services."
  value       = module.ecr.repository_names
}