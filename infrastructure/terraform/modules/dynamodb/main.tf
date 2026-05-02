resource "aws_dynamodb_table" "carts" {
  name         = "shopcloud-carts-${var.env}"
  billing_mode = var.billing_mode
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "shopcloud-carts-${var.env}"
    Env  = var.env
  }
}
