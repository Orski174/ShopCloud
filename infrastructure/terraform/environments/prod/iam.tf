# Reference existing GitHub OIDC provider created by dev environment
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Data source to pass to IAM module
locals {
  github_oidc_provider_arn = data.aws_iam_openid_connect_provider.github.arn
}
