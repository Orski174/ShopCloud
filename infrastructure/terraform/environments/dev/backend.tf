terraform {
  backend "s3" {
    bucket         = "shopcloud-tfstate-dev"
    key            = "shopcloud/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shopcloud-tflock-dev"
    encrypt        = true
  }
}
