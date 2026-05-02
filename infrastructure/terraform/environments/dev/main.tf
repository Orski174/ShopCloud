# Use existing default VPC — skip vpc module to avoid free tier VPC limit (max 5 per region)
# All other modules will use local.vpc_id and local.public/private_subnet_ids from data.tf

# TODO: WAF rule reference issue with AWS provider v5.50 — skipping for now
# module "waf" {
#   source = "../../modules/waf"
#   providers = {
#     aws = aws.us_east_1
#   }
#
#   env = var.env
# }

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
  min_capacity              = 0.5
  max_capacity              = 4
  skip_final_snapshot       = true
  backup_retention_period   = 1
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  env          = var.env
  billing_mode = "PAY_PER_REQUEST"
}

module "frontend_hosting" {
  source = "../../modules/frontend_hosting"

  env            = var.env
  aws_account_id = var.aws_account_id
}

module "iam" {
  source = "../../modules/iam"

  env                                  = var.env
  aws_account_id                       = var.aws_account_id
  github_org                           = var.github_org
  github_repo                          = var.github_repo
  dynamodb_table_arn                   = module.dynamodb.table_arn
  s3_invoices_bucket_arn               = module.s3.invoices_bucket_arn
  s3_images_bucket_arn                 = module.s3.images_bucket_arn
  frontend_bucket_arn                  = module.frontend_hosting.bucket_arn
  frontend_cloudfront_distribution_arn = module.frontend_hosting.cloudfront_distribution_arn
  sqs_invoice_queue_arn                = aws_sqs_queue.invoice_queue.arn
  rds_secret_arn                       = module.rds.db_secret_arn
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

module "ecr" {
  source = "../../modules/ecr"

  env      = var.env
  services = var.services
}

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
  db_secret_arn          = module.rds.db_secret_arn
  db_host                = module.rds.cluster_endpoint
  db_name                = var.db_name
  db_username            = var.db_username
  dynamodb_table_name    = module.dynamodb.table_name
  s3_invoices_bucket     = module.s3.invoices_bucket_name
  s3_images_bucket       = module.s3.images_bucket_name
  sqs_invoice_queue_url  = aws_sqs_queue.invoice_queue.url
  services               = var.services
  cpu = {
    auth     = 256
    catalog  = 512
    cart     = 256
    checkout = 512
    admin    = 256
    invoice  = 256
  }
  memory = {
    auth     = 512
    catalog  = 1024
    cart     = 512
    checkout = 1024
    admin    = 512
    invoice  = 512
  }
  desired_count = {
    auth     = 1
    catalog  = 1
    cart     = 1
    checkout = 1
    admin    = 1
    invoice  = 1
  }
  image_tag = "latest"
}

module "monitoring" {
  source = "../../modules/monitoring"

  env                           = var.env
  cluster_name                  = module.ecs.cluster_name
  alb_arn_suffix                = module.alb.public_alb_arn_suffix
  target_group_arn_suffixes     = module.alb.target_group_arn_suffixes
  admin_target_group_arn_suffix = module.alb.admin_target_group_arn_suffix
  services                      = var.services
  rds_cluster_id                = split(":", module.rds.cluster_endpoint)[0]
  dynamodb_table_name           = module.dynamodb.table_name
  sqs_queue_name                = aws_sqs_queue.invoice_queue.name
  sqs_dlq_name                  = aws_sqs_queue.invoice_dlq.name
  email_endpoint                = var.email_endpoint
}

# SQS Queue for Invoice Processing
resource "aws_sqs_queue" "invoice_queue" {
  name                       = "shopcloud-invoice-queue-${var.env}"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20

  tags = {
    Name = "shopcloud-invoice-queue-${var.env}"
    Env  = var.env
  }
}

# SQS Dead-Letter Queue
resource "aws_sqs_queue" "invoice_dlq" {
  name = "shopcloud-invoice-dlq-${var.env}"

  tags = {
    Name = "shopcloud-invoice-dlq-${var.env}"
    Env  = var.env
  }
}

# SQS Queue Redrive Policy
resource "aws_sqs_queue_redrive_policy" "invoice_queue" {
  queue_url = aws_sqs_queue.invoice_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.invoice_dlq.arn
    maxReceiveCount     = 3
  })
}

# S3 Images Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "images_cloudfront" {
  bucket = module.s3.images_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontOAC"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${module.s3.images_bucket_arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = module.cloudfront.distribution_arn
        }
      }
    }]
  })

  depends_on = [module.cloudfront]
}
