# ShopCloud Frontend

This is a Vite + React frontend for the implemented ShopCloud backend services.

## Run Locally

From the repository root, start the backend:

```powershell
docker compose up --build
```

In another terminal, start the frontend:

```powershell
cd frontend
npm install
npm run dev
```

Open:

```text
http://localhost:5173
```

## Build Locally

```powershell
cd frontend
npm ci
npm run build
```

The production-ready static files are written to `frontend/dist/`.

## Environment Variables

Copy `.env.example` to `.env` if you need to override backend URLs.

```text
VITE_AUTH_API_URL=http://localhost:3001
VITE_CATALOG_API_URL=http://localhost:3002
VITE_CART_API_URL=http://localhost:3003
VITE_CHECKOUT_API_URL=http://localhost:3004
VITE_ADMIN_API_URL=http://localhost:3005
VITE_INVOICE_API_URL=http://localhost:3006
```

Vite reads these variables at build time. In GitHub Actions, set the production values before running `npm run build`; changing them after upload does not change an already-built frontend bundle.

## AWS Deployment

The frontend is deployed as static files, separate from the backend ECS services:

1. GitHub Actions checks out the repo and builds `frontend/dist/`.
2. The workflow uploads `frontend/dist/` to the frontend S3 bucket.
3. CloudFront serves the private S3 bucket through Origin Access Control.
4. The workflow creates a CloudFront invalidation so users receive the newest React build.

The deployment workflow is `.github/workflows/frontend-deploy.yml`. It runs on pushes to `main` or `master`, and can also be started manually from GitHub Actions. Pull requests only run the CI build check and do not deploy.

### Required GitHub Actions Settings

Set these as repository variables or secrets:

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

The repository already uses GitHub OIDC for AWS access. For frontend deployment, set one of these secrets to the Terraform `github_actions_role_arn` output:

```text
AWS_ROLE_TO_ASSUME
PROD_DEPLOY_ROLE_ARN
```

`PROD_DEPLOY_ROLE_ARN` is already used by the existing production backend deployment workflow. `AWS_ROLE_TO_ASSUME` is a generic alternative supported by the frontend deployment workflow.

### Verify AWS Deployment

After the workflow succeeds:

```powershell
aws s3 ls s3://<FRONTEND_S3_BUCKET>/
aws cloudfront get-distribution --id <CLOUDFRONT_DISTRIBUTION_ID>
```

Then open the Terraform `frontend_cloudfront_domain_name` output in a browser and verify:

- The home page loads.
- Refreshing a client route such as `/cart` or `/orders` still returns the React app.
- The browser network tab shows API calls going to the configured production service URLs.

## CI/CD Demo Explanation

- Backend services deploy through Docker images pushed to ECR and ECS/Fargate service updates.
- The React/Vite frontend deploys through S3 and CloudFront, not ECS.
- GitHub Actions automates both flows.
- Terraform provisions the AWS infrastructure.
- CloudFront invalidation is needed because the edge cache can otherwise keep serving an older `index.html`.

## Demo Flow

1. Register or login as a customer.
2. Browse products on the storefront.
3. Add a product to the cart.
4. Open the cart, update quantity, or remove an item.
5. Continue to checkout and submit `line1`, `city`, and `country`.
6. View the created order on the Orders page.
7. Login as admin using the seeded backend account.
8. Open the Admin Dashboard to view products and orders.
9. Update a product stock quantity from the admin products table.

Seeded admin credentials from the backend seeder:

```text
Email: admin@shopcloud.com
Password: Admin1234!
```

## Backend Endpoints Used

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/admin/login`
- `GET /products`
- `GET /products/search?q=...`
- `GET /cart/:userId`
- `POST /cart/:userId/items`
- `PUT /cart/:userId/items/:productId`
- `DELETE /cart/:userId/items/:productId`
- `POST /checkout`
- `GET /orders`
- `GET /admin/products`
- `GET /admin/orders`
- `PUT /admin/products/:id/stock`

## Notes

- Invoice generation is not directly displayed in the UI because the implemented backend creates invoices asynchronously after checkout and stores the PDF in S3 or LocalStack.
- The admin dashboard is API-based. The backend does not include a separate admin UI.
