resource "aws_ecr_repository" "service" {
  for_each = toset(var.services)

  name                 = "shopcloud/${each.value}"
  image_tag_mutability = var.env == "prod" ? "IMMUTABLE" : "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = "ShopCloud"
    Environment = var.env
    Service     = each.value
  }
}