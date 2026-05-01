variable "env" {
  description = "Deployment environment name, such as dev or prod."
  type        = string
}

variable "services" {
  description = "List of ShopCloud services that need ECR repositories."
  type        = list(string)
}