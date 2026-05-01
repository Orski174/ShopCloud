output "repository_urls" {
  description = "Map of service name to ECR repository URL."
  value = {
    for service, repo in aws_ecr_repository.service :
    service => repo.repository_url
  }
}

output "repository_names" {
  description = "Map of service name to ECR repository name."
  value = {
    for service, repo in aws_ecr_repository.service :
    service => repo.name
  }
}