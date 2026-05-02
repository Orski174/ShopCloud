# Use existing default VPC — skip vpc module to avoid free tier VPC limit (max 5 per region)
# All other modules will use local.vpc_id and local.public/private_subnet_ids from data.tf

module "s3" {
  source = "../../modules/s3"

  env            = var.env
  aws_account_id = var.aws_account_id
}

module "rds" {
  source = "../../modules/rds"

  env                       = var.env
  vpc_id                    = local.vpc_id
  private_subnet_ids        = local.private_subnet_ids
  db_name                   = var.db_name
  db_username               = var.db_username
  allowed_security_group_id = module.alb.public_alb_sg_id
  ecs_security_group_id     = module.ecs.ecs_sg_id
  min_capacity              = 1
  max_capacity              = 16
  skip_final_snapshot       = false
  backup_retention_period   = 1  # Free tier maximum
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  env          = var.env
  billing_mode = "PAY_PER_REQUEST"
}

module "iam" {
  source = "../../modules/iam"

  env                          = var.env
  aws_account_id               = var.aws_account_id
  github_org                   = var.github_org
  github_repo                  = var.github_repo
  dynamodb_table_arn           = module.dynamodb.table_arn
  s3_invoices_bucket_arn       = module.s3.invoices_bucket_arn
  s3_images_bucket_arn         = module.s3.images_bucket_arn
  sqs_invoice_queue_arn        = aws_sqs_queue.invoice_queue.arn
  rds_secret_arn               = module.rds.db_secret_arn
  create_oidc_provider         = false  # Use existing provider created by dev
  existing_oidc_provider_arn   = local.github_oidc_provider_arn
}

module "alb" {
  source = "../../modules/alb"

  env                = var.env
  vpc_id             = local.vpc_id
  public_subnet_ids  = local.public_subnet_ids
  private_subnet_ids = local.private_subnet_ids
  services = {
    auth     = { port = 3001, health_check_path = "/health" }
    catalog  = { port = 3002, health_check_path = "/health" }
    cart     = { port = 3003, health_check_path = "/health" }
    checkout = { port = 3004, health_check_path = "/health" }
    invoice  = { port = 3006, health_check_path = "/health" }
  }
  enable_ssl = false
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  env                  = var.env
  alb_dns_name         = module.alb.public_alb_dns_name
  images_bucket_domain = module.s3.images_bucket_domain_name
  images_bucket_arn    = module.s3.images_bucket_arn
  waf_acl_arn          = ""  # WAF temporarily disabled
}

# ECR repositories are shared across environments (created by dev)
# See ecr.tf for data source references

module "ecs" {
  source = "../../modules/ecs"

  env                = var.env
  aws_region         = var.aws_region
  aws_account_id     = var.aws_account_id
  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids
  alb_sg_id          = module.alb.public_alb_sg_id
  ecs_exec_role_arn  = module.iam.ecs_exec_role_arn
  task_role_arns = {
    auth     = module.iam.auth_task_role_arn
    catalog  = module.iam.catalog_task_role_arn
    cart     = module.iam.cart_task_role_arn
    checkout = module.iam.checkout_task_role_arn
    admin    = module.iam.admin_task_role_arn
    invoice  = module.iam.invoice_task_role_arn
  }
  target_group_arns      = module.alb.target_group_arns
  admin_target_group_arn = module.alb.admin_target_group_arn
  db_host                = module.rds.cluster_endpoint
  db_secret_arn          = module.rds.db_secret_arn
  dynamodb_table_name    = module.dynamodb.table_name
  sqs_invoice_queue_url  = aws_sqs_queue.invoice_queue.url
  s3_invoices_bucket     = module.s3.invoices_bucket_name
  s3_images_bucket       = module.s3.images_bucket_name
  image_tag              = "latest"
  services               = var.services
  cpu = {
    auth     = 256
    catalog  = 256
    cart     = 256
    checkout = 512
    admin    = 256
    invoice  = 256
  }
  memory = {
    auth     = 512
    catalog  = 512
    cart     = 512
    checkout = 1024
    admin    = 512
    invoice  = 1024
  }
  desired_count = {
    auth     = 2
    catalog  = 2
    cart     = 2
    checkout = 2
    admin    = 1
    invoice  = 1
  }
}

# SQS queues for async invoice processing
resource "aws_sqs_queue" "invoice_queue" {
  name                      = "shopcloud-invoice-queue-${var.env}"
  visibility_timeout_seconds = 300
  message_retention_seconds = 86400
  receive_wait_time_seconds = 20

  tags = {
    Env = var.env
  }
}

resource "aws_sqs_queue" "invoice_dlq" {
  name = "shopcloud-invoice-dlq-${var.env}"

  tags = {
    Env = var.env
  }
}

resource "aws_sqs_queue_redrive_policy" "invoice_queue" {
  queue_url             = aws_sqs_queue.invoice_queue.id
  redrive_policy        = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.invoice_dlq.arn
    maxReceiveCount     = 3
  })
}

module "monitoring" {
  source = "../../modules/monitoring"

  env                            = var.env
  cluster_name                   = module.ecs.cluster_name
  services                       = var.services
  alb_arn_suffix                 = module.alb.public_alb_arn_suffix
  target_group_arn_suffixes      = module.alb.target_group_arn_suffixes
  admin_target_group_arn_suffix  = split("/", module.alb.admin_target_group_arn)[2]
  rds_cluster_id                 = split(":", module.rds.cluster_endpoint)[0]
  dynamodb_table_name            = module.dynamodb.table_name
  sqs_queue_name                 = aws_sqs_queue.invoice_queue.name
  sqs_dlq_name                   = aws_sqs_queue.invoice_dlq.name
  email_endpoint                 = "noreply@example.com"
}
