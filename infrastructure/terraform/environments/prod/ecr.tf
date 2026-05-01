# Reference existing ECR repositories created by dev environment
# ECR repos are environment-agnostic and shared across dev/prod
data "aws_ecr_repository" "existing" {
  for_each = toset(["auth", "catalog", "cart", "checkout", "admin", "invoice"])
  name     = "shopcloud/${each.value}"
}

locals {
  ecr_repository_urls = {
    for service, repo in data.aws_ecr_repository.existing : service => repo.repository_url
  }
  ecr_repository_names = {
    for service, repo in data.aws_ecr_repository.existing : service => repo.name
  }
}

output "repository_urls" {
  description = "ECR repository URLs"
  value       = local.ecr_repository_urls
}

output "repository_names" {
  description = "ECR repository names"
  value       = local.ecr_repository_names
}
