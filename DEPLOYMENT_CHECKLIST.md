# Deployment Verification Checklist

This checklist ensures the ShopCloud Terraform infrastructure is ready for deployment.

## Pre-Deployment Verification ✅

### Code Quality
- [x] All 43 Terraform files present and accounted for
- [x] HCL syntax validated (matched braces)
- [x] Code formatted with `terraform fmt`
- [x] No critical configuration issues
- [x] 11 modules properly structured (3 files each)
- [x] 2 complete environments (dev + prod)

### Configuration Completeness
- [x] Dev environment has 11 modules integrated
- [x] Prod environment has 11 modules integrated
- [x] All required variables defined in each environment
- [x] Backend configuration present (S3 + DynamoDB)
- [x] Provider aliases configured for multi-region
- [x] terraform.tfvars templates created

### Module Integration
- [x] VPC module outputs feed into security groups
- [x] IAM roles feed into ECS and Lambda
- [x] RDS endpoint feeds into ECS environment variables
- [x] DynamoDB table name feeds into ECS
- [x] S3 bucket ARNs feed into IAM policies
- [x] ALB outputs feed into CloudFront
- [x] CloudFront feeds into monitoring module
- [x] SQS queues created in both environments

### CI/CD Pipeline
- [x] GitHub Actions workflows created
- [x] Dev deploy workflow triggers on `dev` branch
- [x] Prod deploy workflow triggers on `main` branch
- [x] OIDC provider configuration ready
- [x] Health check endpoints defined
- [x] Service update logic implemented
- [x] Artifact upload/download configured

### Security
- [x] IAM task roles use least-privilege
- [x] Per-service permissions configured
- [x] GitHub OIDC role ready (no hardcoded credentials)
- [x] Security groups restrict traffic appropriately
- [x] S3 encryption enabled
- [x] RDS uses Secrets Manager
- [x] WAF configured with managed rules
- [x] WAF rate limiting enabled (2000 req/5min)

## Pre-Deployment Manual Setup

Before running `terraform apply`, complete these one-time tasks:

### 1. Create S3 State Buckets

**Dev Account:**
```bash
aws s3 mb s3://shopcloud-tfstate-dev --region us-east-1
aws s3api put-bucket-versioning \
  --bucket shopcloud-tfstate-dev \
  --versioning-configuration Status=Enabled
```

**Prod Account:**
```bash
aws s3 mb s3://shopcloud-tfstate-prod --region us-east-1
aws s3api put-bucket-versioning \
  --bucket shopcloud-tfstate-prod \
  --versioning-configuration Status=Enabled
```

### 2. Create DynamoDB Lock Tables

**Dev Account:**
```bash
aws dynamodb create-table \
  --table-name shopcloud-tflock-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**Prod Account:**
```bash
aws dynamodb create-table \
  --table-name shopcloud-tflock-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 3. Update terraform.tfvars

Edit `environments/dev/terraform.tfvars`:
```hcl
aws_account_id = "123456789012"  # Your dev AWS account ID
```

Edit `environments/prod/terraform.tfvars`:
```hcl
aws_account_id = "987654321098"  # Your prod AWS account ID
```

### 4. Configure GitHub Actions Secrets

Set these in GitHub Settings → Secrets and Variables → Actions:

After first Terraform apply, retrieve these from outputs:
- `DEV_DEPLOY_ROLE_ARN` → IAM module output
- `PROD_DEPLOY_ROLE_ARN` → IAM module output

## Deployment Commands

### Initialize and Plan Dev

```bash
cd project/infrastructure/terraform/environments/dev

# Initialize with backend
terraform init

# Create plan file
terraform plan -out=tfplan

# Review changes
cat tfplan  # outputs in binary, but Terraform shows summary
```

### Apply Dev

```bash
# Apply plan
terraform apply tfplan

# Capture outputs
terraform output > dev-outputs.txt
```

### Verify Dev Deployment

After `terraform apply`:

```bash
# Check ECS cluster
aws ecs list-clusters --region us-east-1

# Check ALB
aws elbv2 describe-load-balancers --region us-east-1 --names shopcloud-public-dev

# Check RDS
aws rds describe-db-clusters \
  --region us-east-1 \
  --query 'DBClusters[?contains(DBClusterIdentifier, `shopcloud-dev`)]'

# Check CloudFront
aws cloudfront list-distributions --query 'DistributionList.Items[?Comment==`ShopCloud CDN - dev`]'
```

### Initialize and Plan Prod

```bash
cd ../../prod

terraform init
terraform plan -out=tfplan
```

### Apply Prod

```bash
terraform apply tfplan
terraform output > prod-outputs.txt
```

## Post-Deployment Verification

### 1. VPC & Networking
```bash
# List VPCs
aws ec2 describe-vpcs --region us-east-1 \
  --query 'Vpcs[?Tags[?Key==`Name`]].VpcId'

# Check subnets
aws ec2 describe-subnets --region us-east-1 \
  --query 'Subnets[?Tags[?Key==`Env`]].{Id:SubnetId,CIDR:CidrBlock}'

# Verify NAT Gateway
aws ec2 describe-nat-gateways --region us-east-1 \
  --query 'NatGateways[?State==`available`]'
```

### 2. Database
```bash
# Check RDS cluster
aws rds describe-db-clusters --region us-east-1 \
  --query 'DBClusters[?contains(DBClusterIdentifier, `dev`)].Status'

# Verify secret in Secrets Manager
aws secretsmanager describe-secret \
  --secret-id shopcloud/rds/password/dev \
  --region us-east-1
```

### 3. Storage
```bash
# List S3 buckets
aws s3 ls | grep shopcloud

# Check bucket versioning
aws s3api get-bucket-versioning \
  --bucket shopcloud-invoices-dev-123456789012
```

### 4. Compute
```bash
# List ECS clusters
aws ecs list-clusters --region us-east-1

# List services in cluster
aws ecs list-services --cluster shopcloud-dev --region us-east-1

# Check task definitions
aws ecs list-task-definitions \
  --family-prefix shopcloud \
  --region us-east-1
```

### 5. Load Balancing
```bash
# Get ALB DNS name
aws elbv2 describe-load-balancers \
  --names shopcloud-public-dev \
  --region us-east-1 \
  --query 'LoadBalancers[0].DNSName'

# Verify target groups
aws elbv2 describe-target-groups \
  --load-balancer-arn arn:aws:elasticloadbalancing:... \
  --region us-east-1
```

### 6. CDN
```bash
# Get CloudFront distribution
aws cloudfront list-distributions \
  --query 'DistributionList.Items[?Comment==`ShopCloud CDN - dev`].DomainName'
```

## Rollback Procedure

If deployment fails or needs rollback:

```bash
# Destroy specific resource
terraform destroy -target=module.ecs

# Destroy entire environment
terraform destroy

# Confirm destruction
aws ec2 describe-vpcs --region us-east-1 \
  --query 'Vpcs[?Tags[?Key==`Env`]&&Tags[?Value==`dev`]]'
```

## Troubleshooting

### State Lock Issues
```bash
# Unlock state
aws dynamodb delete-item \
  --table-name shopcloud-tflock-dev \
  --key '{"LockID": {"S": "shopcloud/dev/terraform.tfstate"}}' \
  --region us-east-1
```

### Provider Configuration Errors
- Ensure `AWS_REGION` or `aws_region` variable is set
- Check `~/.aws/credentials` and `~/.aws/config`
- Verify IAM permissions for Terraform user/role

### Module Not Found
```bash
# Re-initialize modules
terraform get -update
terraform init -upgrade
```

### Backend Access Errors
- Verify S3 bucket exists and is accessible
- Check DynamoDB table exists
- Ensure IAM permissions for state bucket

## Monitoring Post-Deployment

### CloudWatch Alarms
```bash
# List all alarms
aws cloudwatch describe-alarms \
  --region us-east-1 \
  --query 'MetricAlarms[?Namespace==`AWS/ApplicationELB`]'

# Check specific alarm
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 300 \
  --statistics Average
```

### ECS Health Checks
```bash
# Get service status
aws ecs describe-services \
  --cluster shopcloud-dev \
  --services shopcloud-auth-dev \
  --region us-east-1 \
  --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}'

# View task status
aws ecs list-tasks --cluster shopcloud-dev --region us-east-1 | \
  jq '.taskArns[0]' | xargs -I {} \
  aws ecs describe-tasks --cluster shopcloud-dev --tasks {} --region us-east-1
```

## Success Criteria

✅ All infrastructure deployed successfully
✅ VPC with public/private subnets created
✅ RDS Aurora cluster accessible
✅ DynamoDB table created and accessible
✅ S3 buckets created with versioning
✅ ECS cluster with services deployed
✅ ALB routing traffic to services
✅ CloudFront distribution active
✅ CloudWatch alarms firing
✅ SNS topics configured
✅ GitHub Actions workflows ready
✅ No errors in CloudWatch logs

## Next Steps

1. Build and push Docker images to ECR
2. Run database migrations via ECS task
3. Test services via ALB endpoint
4. Verify CloudFront distribution serves content
5. Trigger deployment workflows
6. Monitor CloudWatch metrics and alarms
7. Perform end-to-end functionality tests
8. Load test with concurrent users
9. Test failover scenarios
10. Document lessons learned
