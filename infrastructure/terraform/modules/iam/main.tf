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
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSDeployment"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTaskDefinitionFamilies",
          "ecs:DescribeClusters",
          "ecs:ListClusters",
          "ecs:ListServices"
        ]
        Resource = "*"
      },
      {
        Sid    = "EKSClusterManagement"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster",
          "eks:DeleteCluster",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterVersion",
          "eks:UpdateClusterConfig",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:UpdateNodegroupVersion",
          "eks:UpdateNodegroupConfig"
        ]
        Resource = "arn:aws:eks:*:${var.aws_account_id}:cluster/shopcloud-*"
      },
      {
        Sid    = "EKSImagePullPush"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMRoleManagement"
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/shopcloud-*",
          aws_iam_role.ecs_exec.arn,
          aws_iam_role.auth_task.arn,
          aws_iam_role.catalog_task.arn,
          aws_iam_role.cart_task.arn,
          aws_iam_role.checkout_task.arn,
          aws_iam_role.admin_task.arn,
          aws_iam_role.invoice_task.arn
        ]
      },
      {
        Sid    = "EC2ResourcesForEKS"
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateTags",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "KubernetesAuth"
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = "arn:aws:iam::${var.aws_account_id}:role/shopcloud-eks-*"
      }
    ]
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# EKS Cluster Service Role
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "eks_cluster" {
  name = "shopcloud-eks-cluster-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

# Attach AWS managed policy for EKS cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach VPC CNI policy
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# ─────────────────────────────────────────────────────────────────────────────
# EKS Node Group Service Role
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "eks_node" {
  name = "shopcloud-eks-node-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

# Attach AWS managed policies for EKS nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# Allow nodes to read from ECR
resource "aws_iam_role_policy" "eks_node_ecr" {
  name = "shopcloud-eks-node-ecr-${var.env}"
  role = aws_iam_role.eks_node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
      Resource = "*"
    }]
  })
}

# Create instance profile for nodes
resource "aws_iam_instance_profile" "eks_node" {
  name = "shopcloud-eks-node-profile-${var.env}"
  role = aws_iam_role.eks_node.name
}

# ─────────────────────────────────────────────────────────────────────────────
# OIDC Provider for EKS (for IRSA - IAM Roles for Service Accounts)
# ─────────────────────────────────────────────────────────────────────────────

data "tls_certificate" "eks_oidc" {
  url = "https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLEJWTOKENEXAMPLE"
  # This will be overridden by actual cluster endpoint
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  url             = "https://oidc.eks.us-east-1.amazonaws.com"

  tags = {
    Env = var.env
  }
}

# Service account role for EKS deployments (for pulling from ECR)
resource "aws_iam_role" "eks_service_account" {
  name = "shopcloud-eks-service-account-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Condition = {
        StringEquals = {
          "oidc.eks.us-east-1.amazonaws.com:sub" = "system:serviceaccount:default:shopcloud-sa"
        }
      }
    }]
  })

  tags = {
    Env = var.env
  }
}

# ECR access for EKS service account
resource "aws_iam_role_policy" "eks_service_account_ecr" {
  name = "shopcloud-eks-sa-ecr-${var.env}"
  role = aws_iam_role.eks_service_account.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
      Resource = "*"
    }]
  })
}
