# ShopCloud Terraform

Terraform provisions the AWS infrastructure for both deployment paths:

- Backend: ECR repositories, ECS/Fargate services, ALBs, data stores, queues, and IAM roles.
- Frontend: a private S3 bucket for `frontend/dist/` and a CloudFront distribution using Origin Access Control.

## Frontend Hosting

The `modules/frontend_hosting` module creates:

- `shopcloud-frontend-<env>-<account-id>` S3 bucket
- S3 public access blocking
- S3 server-side encryption and versioning
- CloudFront Origin Access Control
- CloudFront distribution with `index.html` as the default root object
- SPA fallback for `403` and `404`, so routes like `/cart` and `/orders` load correctly

Environment outputs expose the values required by GitHub Actions:

```text
frontend_bucket_name
frontend_cloudfront_domain_name
frontend_cloudfront_distribution_id
github_actions_role_arn
```

## Apply

```bash
cd infrastructure/terraform/environments/dev
terraform init
terraform plan
terraform apply
```

For production:

```bash
cd infrastructure/terraform/environments/prod
terraform init
terraform plan
terraform apply
```

## GitHub Actions Configuration

The repo uses GitHub OIDC rather than long-lived AWS keys. Put the Terraform `github_actions_role_arn` output in GitHub Actions secrets:

```text
DEV_DEPLOY_ROLE_ARN   # dev backend workflow
PROD_DEPLOY_ROLE_ARN  # prod backend workflow and optional frontend fallback
AWS_ROLE_TO_ASSUME    # optional generic frontend deploy role secret
```

Set these frontend deployment values as repository variables or secrets:

```text
AWS_REGION
FRONTEND_S3_BUCKET
CLOUDFRONT_DISTRIBUTION_ID
VITE_AUTH_API_URL
VITE_CATALOG_API_URL
VITE_CART_API_URL
VITE_CHECKOUT_API_URL
VITE_ADMIN_API_URL
VITE_INVOICE_API_URL
```

Use `frontend_bucket_name` for `FRONTEND_S3_BUCKET` and `frontend_cloudfront_distribution_id` for `CLOUDFRONT_DISTRIBUTION_ID`.

## IAM Permissions

The GitHub Actions OIDC role can still deploy backend services through ECR/ECS. It also has the minimum frontend permissions needed by `.github/workflows/frontend-deploy.yml`:

- `s3:ListBucket` and `s3:GetBucketLocation` on the frontend bucket
- `s3:PutObject`, `s3:DeleteObject`, and `s3:GetObject` on frontend bucket objects
- `cloudfront:CreateInvalidation` on the frontend CloudFront distribution

## Course Demo Talking Points

- Backend services are containerized and deployed by GitHub Actions to ECR and ECS/Fargate.
- The frontend is static after `npm run build`, so it is cheaper and simpler to host through S3 and CloudFront.
- Terraform creates the infrastructure and outputs the values that GitHub Actions needs.
- The frontend workflow injects `VITE_*` API URLs at build time.
- CloudFront invalidation makes the new `index.html` visible quickly after each deployment.
