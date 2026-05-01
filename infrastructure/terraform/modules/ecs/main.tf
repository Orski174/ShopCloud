resource "aws_ecs_cluster" "main" {
  name = "shopcloud-${var.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "shopcloud-${var.env}"
    Env  = var.env
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = var.env == "prod" ? ["FARGATE"] : ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  dynamic "default_capacity_provider_strategy" {
    for_each = var.env == "prod" ? [] : [1]
    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = 50
    }
  }
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "shopcloud-ecs-${var.env}"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  # Allow traffic from ALB
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # Allow traffic from internal ALB
  ingress {
    from_port   = 3005
    to_port     = 3005
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shopcloud-ecs-${var.env}"
    Env  = var.env
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "services" {
  for_each = toset(var.services)

  name              = "/ecs/shopcloud-${each.value}-${var.env}"
  retention_in_days = var.env == "prod" ? 90 : 30

  tags = {
    Name = "shopcloud-${each.value}-${var.env}"
    Env  = var.env
  }
}

# Task Definitions
resource "aws_ecs_task_definition" "services" {
  for_each = toset(var.services)

  family                   = "shopcloud-${each.value}-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu[each.value]
  memory                   = var.memory[each.value]
  execution_role_arn       = var.ecs_exec_role_arn
  task_role_arn            = var.task_role_arns[each.value]

  container_definitions = jsonencode([{
    name      = each.value
    image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/shopcloud/${each.value}:${var.image_tag}"
    essential = true

    portMappings = [{
      containerPort = lookup({
        auth     = 3001
        catalog  = 3002
        cart     = 3003
        checkout = 3004
        admin    = 3005
        invoice  = 3006
      }, each.value)
      protocol = "tcp"
    }]

    environment = concat(
      [
        {
          name  = "NODE_ENV"
          value = var.env
        },
        {
          name  = "DB_HOST"
          value = var.db_host
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "AUTH_SERVICE_URL"
          value = "http://shopcloud-auth-${var.env}.internal:3001"
        },
        {
          name  = "CATALOG_SERVICE_URL"
          value = "http://shopcloud-catalog-${var.env}.internal:3002"
        },
        {
          name  = "CART_SERVICE_URL"
          value = "http://shopcloud-cart-${var.env}.internal:3003"
        },
        {
          name  = "CHECKOUT_SERVICE_URL"
          value = "http://shopcloud-checkout-${var.env}.internal:3004"
        },
        {
          name  = "INVOICE_SERVICE_URL"
          value = "http://shopcloud-invoice-${var.env}.internal:3006"
        },
      ],
      each.value == "cart" ? [
        {
          name  = "DYNAMODB_TABLE"
          value = var.dynamodb_table_name
        }
      ] : [],
      each.value == "invoice" ? [
        {
          name  = "S3_INVOICES_BUCKET"
          value = var.s3_invoices_bucket
        }
      ] : [],
      each.value == "invoice" && var.sqs_invoice_queue_url != "" ? [
        {
          name  = "SQS_QUEUE_URL"
          value = var.sqs_invoice_queue_url
        }
      ] : []
    )

    secrets = [
      {
        name      = "DB_PASSWORD"
        valueFrom = "${var.db_secret_arn}:password::"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.services[each.value].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name = "shopcloud-${each.value}-${var.env}"
    Env  = var.env
  }
}

# ECS Services
resource "aws_ecs_service" "services" {
  for_each = toset(var.services)

  name            = "shopcloud-${each.value}-${var.env}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.value].arn
  desired_count   = var.desired_count[each.value]
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = each.value == "admin" ? var.admin_target_group_arn : var.target_group_arns[each.value]
    container_name   = each.value
    container_port = lookup({
      auth     = 3001
      catalog  = 3002
      cart     = 3003
      checkout = 3004
      admin    = 3005
      invoice  = 3006
    }, each.value)
  }

  depends_on = [
    aws_ecs_task_definition.services
  ]

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  tags = {
    Name = "shopcloud-${each.value}-${var.env}"
    Env  = var.env
  }
}

# Auto-scaling targets for sensitive services
resource "aws_appautoscaling_target" "ecs_target" {
  for_each = toset(var.env == "prod" ? ["catalog", "checkout"] : [])

  max_capacity       = var.desired_count[each.value] * 2
  min_capacity       = var.desired_count[each.value]
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.services[each.value].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  for_each = toset(var.env == "prod" ? ["catalog", "checkout"] : [])

  name               = "shopcloud-${each.value}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.value].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.value].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.value].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60.0
  }
}
