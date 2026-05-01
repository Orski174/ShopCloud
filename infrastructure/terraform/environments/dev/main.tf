module "ecr" {
  source = "../../modules/ecr"

  env      = var.env
  services = var.services
}