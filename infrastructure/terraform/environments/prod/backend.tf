terraform {
  backend "s3" {
    bucket         = "shopcloud-tfstate-prod"
    key            = "shopcloud/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shopcloud-tflock-prod"
    encrypt        = true
  }
}
