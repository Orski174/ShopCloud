# Use existing default VPC and subnets to avoid free tier VPC limit
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"]
  }
}

locals {
  vpc_id              = data.aws_vpc.default.id
  public_subnet_ids   = data.aws_subnets.default.ids
  private_subnet_ids  = data.aws_subnets.default.ids  # In free tier, we'll use same subnets for now
}
