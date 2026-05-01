# ShopCloud Infrastructure as Code (Terraform)

This directory contains the complete Terraform infrastructure code for deploying ShopCloud across AWS environments.

## Project Structure

```
infrastructure/
├── terraform/
│   ├── modules/              # Reusable infrastructure modules
│   │   ├── vpc/              # VPC, subnets, routing, NAT gateway
│   │   ├── iam/              # IAM roles, policies, GitHub OIDC
│   │   ├── rds/              # Aurora PostgreSQL Serverless v2
│   │   ├── dynamodb/         # DynamoDB shopping cart table
│   │   ├── s3/               # S3 buckets (invoices, images)
│   │   ├── waf/              # AWS WAF with managed rules
│   │   ├── cloudfront/       # CloudFront CDN distribution
│   │   ├── alb/              # Application Load Balancers
│   │   ├── ecs/              # ECS cluster, task defs, services
│   │   ├── ecr/              # ECR repositories
│   │   └── monitoring/       # CloudWatch alarms & SNS
│   ├── environments/
│   │   ├── dev/              # Development environment
│   │   └── prod/             # Production environment
│   └── bootstrap/            # State backend setup (manual)
└── monitoring/
    └── dashboards/           # CloudWatch dashboard configs
```

## Quick Start

### Prerequisites

1. AWS Account(s) - separate dev and prod accounts recommended
2. Terraform >= 1.7.0
3. AWS CLI v2 configured with appropriate IAM permissions
4. GitHub repository with Actions enabled

### Initial Setup (One-time)

#### 1. Create Remote State Backends

Before running Terraform, bootstrap S3 and DynamoDB for state management:

**Dev Account:**
```bash
aws s3 mb s3://shopcloud-tfstate-dev --region us-east-1
aws s3api put-bucket-versioning --bucket shopcloud-tfstate-dev --versioning-configuration Status=Enabled
aws dynamodb create-table \
  --table-name shopcloud-tflock-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**Prod Account:**
```bash
aws s3 mb s3://shopcloud-tfstate-prod --region us-east-1
aws s3api put-bucket-versioning --bucket shopcloud-tfstate-prod --versioning-configuration Status=Enabled
aws dynamodb create-table \
  --table-name shopcloud-tflock-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

#### 2. Set AWS Account IDs

Update `environments/dev/terraform.tfvars` and `environments/prod/terraform.tfvars` with your actual AWS account IDs:

```hcl
aws_account_id = "123456789012"  # Your AWS account ID
```

#### 3. Configure GitHub Actions Secrets

In GitHub repository Settings → Secrets and variables → Actions, add:

- `DEV_DEPLOY_ROLE_ARN` - ARN of the GitHub OIDC role in dev account (output from Terraform)
- `PROD_DEPLOY_ROLE_ARN` - ARN of the GitHub OIDC role in prod account (output from Terraform)

## Deployment

### Development Environment

```bash
cd environments/dev

# Initialize Terraform (sets up backend)
terraform init

# Review planned changes
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan

# Outputs will display important endpoints
```

### Production Environment

```bash
cd environments/prod

# Initialize Terraform
terraform init

# Review plan
terraform plan -out=tfplan

# Apply with approval
terraform apply tfplan
```

## Architecture Overview

### VPC & Networking
- **VPC CIDR**: 10.0.0.0/16 (configurable)
- **Public Subnets**: 2 (one per AZ) - ALBs, NAT Gateway
- **Private Subnets**: 2 (one per AZ) - ECS tasks, RDS, DynamoDB
- **Internet Gateway**: For public subnet routing
- **NAT Gateway**: For private subnet egress

### Database
- **RDS Aurora PostgreSQL** (Serverless v2)
  - Dev: 0.5-4 ACUs
  - Prod: 1-16 ACUs with multi-AZ failover
  - Automatic backups with 1-7 day retention
  - Secret stored in AWS Secrets Manager

- **DynamoDB**
  - On-demand billing for shopping carts
  - TTL for session cleanup
  - Point-in-time recovery enabled

### Compute
- **ECS Fargate Cluster** (no EC2 management)
- **6 Microservices**:
  - auth (JWT, user management)
  - catalog (products, categories)
  - cart (shopping cart with DynamoDB)
  - checkout (orders, payment simulation)
  - admin (internal inventory panel)
  - invoice (async PDF generation)

- **Task Specifications**:
  - Dev: 1 task per service
  - Prod: 2+ tasks per service with auto-scaling

### Storage
- **S3 Invoices Bucket** - Versioned, encrypted, lifecycle (Glacier after 90d)
- **S3 Images Bucket** - CloudFront origin, OAC access only
- **CloudFront CDN** - Global distribution with WAF

### Security
- **AWS WAF**
  - AWS Managed Rules (Common, SQLi, Known Bad Inputs)
  - Rate limiting (2000 req/5min per IP)
- **Security Groups**
  - ALB: Allow HTTP/HTTPS from internet
  - ECS: Allow traffic from ALB only
  - RDS: Allow access from ECS only
- **IAM**
  - Per-service task roles (least privilege)
  - GitHub OIDC (no stored credentials)
  - ECS task execution role

### Monitoring & Logging
- **CloudWatch Alarms**:
  - ALB 5xx errors, latency, unhealthy hosts
  - ECS CPU/memory utilization per service
  - RDS CPU and connections
  - DynamoDB throttling
  - SQS DLQ message count
- **CloudWatch Logs**
  - 30 days retention (dev)
  - 90 days retention (prod)
- **SNS Alerts** - Email notifications

## Module Reference

### VPC Module
Creates the network foundation with public/private subnets across AZs.

**Key Variables**:
- `vpc_cidr` - VPC CIDR block
- `public_subnet_cidrs` - Public subnet CIDRs (list of 2)
- `private_subnet_cidrs` - Private subnet CIDRs (list of 2)
- `azs` - Availability zones (list of 2)

**Outputs**:
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`

### IAM Module
Manages all IAM roles with least-privilege policies.

**Roles Created**:
1. ECS Task Execution Role (shared by all services)
2. Per-service Task Roles (6 roles: auth, catalog, cart, checkout, admin, invoice)
3. GitHub Actions OIDC Role (for CI/CD without credentials)

### RDS Module
Aurora PostgreSQL Serverless v2 with high availability.

**Features**:
- Multi-AZ deployment
- Automatic backups
- Secrets Manager integration
- Serverless scaling

### DynamoDB Module
Shopping cart table with TTL and point-in-time recovery.

### S3 Module
Two buckets: one for invoices (private), one for images (CloudFront access).

### WAF Module
AWS Managed Rules and rate limiting (must use us-east-1 provider for CloudFront scope).

### CloudFront Module
CDN with two origins: ALB (API) and S3 (images).

**Cache Behaviors**:
- Default: ALB (no caching for API)
- `/images/*`: S3 (optimized caching)

### ALB Module
Public ALB for customer services, internal ALB for admin.

**Routing**:
- `/auth/*` → auth service
- `/catalog/*`, `/products/*` → catalog service
- `/cart/*` → cart service
- `/checkout/*`, `/orders/*` → checkout service
- `/invoice/*` → invoice service

### ECS Module
Cluster, task definitions, services, and auto-scaling.

**Auto-scaling** (prod only):
- catalog and checkout scale 60% CPU target
- Min: desired_count, Max: desired_count × 2

### ECR Module
Container registries for all services.

### Monitoring Module
CloudWatch alarms and SNS topic for alerts.

## Troubleshooting

### Terraform State Lock
If state is locked, unlock manually:
```bash
aws dynamodb delete-item \
  --table-name shopcloud-tflock-dev \
  --key '{"LockID": {"S": "shopcloud/dev/terraform.tfstate"}}' \
  --region us-east-1
```

### CloudFront WAF Errors
WAF resources must be in us-east-1 and use the `aws.us_east_1` provider alias.

### ECS Task Health Checks
Ensure services implement `/health` endpoint returning 200 OK.

### RDS Connection Issues
Check security group ingress rules allow traffic from ECS SG on port 5432.

## Cost Optimization (Dev)

- Use FARGATE_SPOT capacity provider (50% of tasks)
- Reduce desired task count to 1 per service
- Use smaller RDS capacity (0.5 ACU min)
- DynamoDB on-demand billing (no provisioning)

## Security Best Practices

✅ **Implemented**:
- No public EC2 instances
- Private ECS tasks (no public IPs)
- IAM least-privilege per service
- Secrets Manager for credentials
- WAF at CloudFront edge
- VPC security groups
- S3 versioning & encryption
- RDS backup retention

📝 **Recommendations**:
1. Enable VPC Flow Logs for network monitoring
2. Set up AWS Config for compliance tracking
3. Implement CloudTrail for audit logging
4. Use AWS KMS for additional encryption
5. Set up VPN for admin service access
6. Enable AWS GuardDuty for threat detection

## Maintenance

### Database Backups
- Automated daily (7-day retention in prod)
- Manually restore point-in-time: `aws rds restore-db-cluster-to-point-in-time`

### Container Updates
1. Build new Docker image with updated tag
2. Push to ECR: `docker push REGISTRY/SERVICE:TAG`
3. Update ECS service (GitHub Actions handles this)
4. ECS rolls out gradually (50-200% deployment bounds)

### Terraform Updates
1. `terraform fmt -recursive` - format code
2. `terraform validate` - syntax check
3. `terraform plan` - review changes
4. `terraform apply` - deploy

## Next Steps

1. Deploy infrastructure: `terraform apply` in dev first
2. Build and push Docker images to ECR
3. Run database migrations via ECS task
4. Verify services via ALB/CloudFront endpoints
5. Test CI/CD with a GitHub push
6. Repeat for prod (with manual approval)

## References

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Architecture Best Practices](https://docs.aws.amazon.com/whitepapers/latest/aws-well-architected-framework/)
- [ShopCloud Project README](../../../README.md)
