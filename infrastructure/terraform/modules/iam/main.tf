# ECS Task Execution Role - for ECS agent to pull images and write logs
resource "aws_iam_role" "ecs_exec" {
  name = "shopcloud-ecs-exec-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Inline policy for Secrets Manager access (RDS credentials)
resource "aws_iam_role_policy" "ecs_exec_secrets" {
  name = "shopcloud-ecs-exec-secrets-${var.env}"
  role = aws_iam_role.ecs_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = "arn:aws:secretsmanager:*:${var.aws_account_id}:secret:shopcloud/${var.env}/*"
    }]
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Per-service Task Roles (what container code can call)
# ─────────────────────────────────────────────────────────────────────────────

# Auth service task role
resource "aws_iam_role" "auth_task" {
  name = "shopcloud-auth-task-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

resource "aws_iam_role_policy" "auth_task" {
  name = "shopcloud-auth-task-policy-${var.env}"
  role = aws_iam_role.auth_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = var.rds_secret_arn
    }]
  })
}

# Catalog service task role
resource "aws_iam_role" "catalog_task" {
  name = "shopcloud-catalog-task-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

resource "aws_iam_role_policy" "catalog_task" {
  name = "shopcloud-catalog-task-policy-${var.env}"
  role = aws_iam_role.catalog_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = var.rds_secret_arn
    }]
  })
}

# Cart service task role
resource "aws_iam_role" "cart_task" {
  name = "shopcloud-cart-task-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

resource "aws_iam_role_policy" "cart_task" {
  name = "shopcloud-cart-task-policy-${var.env}"
  role = aws_iam_role.cart_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:UpdateItem"
      ]
      Resource = var.dynamodb_table_arn
    }]
  })
}

# Checkout service task role
resource "aws_iam_role" "checkout_task" {
  name = "shopcloud-checkout-task-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

resource "aws_iam_role_policy" "checkout_task" {
  name = "shopcloud-checkout-task-policy-${var.env}"
  role = aws_iam_role.checkout_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.rds_secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = var.sqs_invoice_queue_arn
      }
    ]
  })
}

# Admin service task role
resource "aws_iam_role" "admin_task" {
  name = "shopcloud-admin-task-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

resource "aws_iam_role_policy" "admin_task" {
  name = "shopcloud-admin-task-policy-${var.env}"
  role = aws_iam_role.admin_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = var.rds_secret_arn
    }]
  })
}

# Invoice service task role
resource "aws_iam_role" "invoice_task" {
  name = "shopcloud-invoice-task-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

resource "aws_iam_role_policy" "invoice_task" {
  name = "shopcloud-invoice-task-policy-${var.env}"
  role = aws_iam_role.invoice_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_invoice_queue_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${var.s3_invoices_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# GitHub Actions OIDC Role for CI/CD
# ─────────────────────────────────────────────────────────────────────────────

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_oidc_provider ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  url             = "https://token.actions.githubusercontent.com"

  tags = {
    Env = var.env
  }
}

# Reference to OIDC provider (either newly created or existing)
locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.existing_oidc_provider_arn
}

resource "aws_iam_role" "github_actions" {
  name = "shopcloud-github-actions-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name = "shopcloud-github-actions-policy-${var.env}"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTaskDefinitionFamilies"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = var.frontend_bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject"
        ]
        Resource = "${var.frontend_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = var.frontend_cloudfront_distribution_arn
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_exec.arn,
          aws_iam_role.auth_task.arn,
          aws_iam_role.catalog_task.arn,
          aws_iam_role.cart_task.arn,
          aws_iam_role.checkout_task.arn,
          aws_iam_role.admin_task.arn,
          aws_iam_role.invoice_task.arn
        ]
      }
    ]
  })
}
