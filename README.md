# ShopCloud

ShopCloud is a lightweight e-commerce backend implemented as six Node.js/Express microservices. The project is designed to run locally with Docker Compose and to map cleanly to an AWS-style deployment architecture.

## Architecture

| Service | Port | Description | Data Store |
|---|---:|---|---|
| auth | 3001 | Customer and admin authentication, JWT issuance | PostgreSQL |
| catalog | 3002 | Product listings, categories, search, stock updates | PostgreSQL |
| cart | 3003 | User shopping carts with TTL | DynamoDB |
| checkout | 3004 | Order creation, stock validation, payment simulation | PostgreSQL + SQS |
| admin | 3005 | Internal product, order, and user management | PostgreSQL |
| invoice | 3006 | Async invoice PDF generation and email notification | S3 + SES + SQS |

## Required Ports

The local stack uses these ports:

| Port | Component |
|---:|---|
| 3001 | auth service |
| 3002 | catalog service |
| 3003 | cart service |
| 3004 | checkout service |
| 3005 | admin service |
| 3006 | invoice service |
| 5432 | PostgreSQL |
| 8000 | DynamoDB Local |
| 9324 | ElasticMQ SQS API |
| 9325 | ElasticMQ UI |
| 4566 | LocalStack |

## Running Locally

### Prerequisites

- Docker
- Docker Compose

### Start All Services

```bash
cd project
docker compose up --build
```

This starts PostgreSQL, DynamoDB Local, ElasticMQ, LocalStack, all six microservices, the database migration runner, and the local AWS bootstrap job.

The migration service automatically creates the PostgreSQL tables and inserts seed data. The AWS bootstrap job creates the DynamoDB cart table and the S3 invoice bucket.

### Health Checks

Run these after the containers are up:

```bash
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
curl http://localhost:3004/health
curl http://localhost:3005/health
curl http://localhost:3006/health
```

Each service should return a JSON response with `"status": "ok"`.

## Seeded Data

The database seeders create sample categories, sample products, and one admin account.

Seeded admin credentials:

```text
Email: admin@shopcloud.com
Password: Admin1234!
```

Seeded categories:

- Electronics
- Clothing
- Home & Kitchen
- Books

Seeded products include headphones, a USB-C hub, clothing items, cookware, and programming books.

## API Demo Flow

The following flow demonstrates the implemented backend from registration through checkout and invoice generation.

### 1. Register a Customer

```bash
curl -X POST http://localhost:3001/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"customer@example.com","password":"Customer123!","name":"Demo Customer"}'
```

Copy the returned `token` and `user.id`.

For the commands below, set:

```bash
export TOKEN="<customer-jwt>"
export USER_ID="<customer-user-id>"
```

### 2. View Products

```bash
curl http://localhost:3002/products
```

Copy a product `id`, `name`, and `price`.

### 3. Add a Product to the Cart

```bash
curl -X POST "http://localhost:3003/cart/$USER_ID/items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"productId":"b2c3d4e5-0002-0002-0002-000000000001","name":"Wireless Headphones","price":149.99,"quantity":1}'
```

### 4. View the Cart

```bash
curl "http://localhost:3003/cart/$USER_ID" \
  -H "Authorization: Bearer $TOKEN"
```

### 5. Checkout

```bash
curl -X POST http://localhost:3004/checkout \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"shipping_address":{"line1":"123 Demo Street","city":"Beirut","country":"Lebanon"}}'
```

Expected result:

- An order is created in PostgreSQL.
- Order items are created.
- Product stock is decremented through the catalog service.
- Payment is simulated as paid.
- The cart is cleared asynchronously.
- An invoice job is published to the SQS-compatible queue.

### 6. View Orders

```bash
curl http://localhost:3004/orders \
  -H "Authorization: Bearer $TOKEN"
```

### 7. Verify Invoice Output in LocalStack S3

After checkout, the invoice worker should generate a PDF and upload it to the local S3 bucket.

If the AWS CLI is available locally:

```bash
aws --endpoint-url http://localhost:4566 s3 ls s3://shopcloud-invoices/invoices/
```

If using the LocalStack container tools:

```bash
docker compose exec localstack awslocal s3 ls s3://shopcloud-invoices/invoices/
```

### 8. Login as Admin

```bash
curl -X POST http://localhost:3001/auth/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@shopcloud.com","password":"Admin1234!"}'
```

Copy the returned admin JWT:

```bash
export ADMIN_TOKEN="<admin-jwt>"
```

### 9. View Admin Orders

```bash
curl http://localhost:3005/admin/orders \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 10. Update Product Stock as Admin

```bash
curl -X PUT http://localhost:3005/admin/products/b2c3d4e5-0002-0002-0002-000000000001/stock \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"stock_quantity":75}'
```

## API Reference

### Auth

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/register` | None | Register a new customer |
| POST | `/auth/login` | None | Customer login and JWT issuance |
| POST | `/auth/admin/login` | None | Admin login and JWT issuance |
| GET | `/auth/me` | Bearer token | Current user profile |
| POST | `/auth/logout` | None | Stateless logout response |

### Catalog

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/products` | None | List products; supports `q`, `category`, `page`, and `limit` |
| GET | `/products/search?q=` | None | Search products |
| GET | `/products/:id` | None | Product detail |
| POST | `/products` | Admin JWT | Create product |
| PUT | `/products/:id` | Admin JWT | Update product |
| DELETE | `/products/:id` | Admin JWT | Delete product |
| PATCH | `/products/:id/stock` | Internal header | Decrement stock for checkout |
| GET | `/categories` | None | List categories |
| GET | `/categories/:slug` | None | Category by slug |
| POST | `/categories` | Admin JWT | Create category |
| PUT | `/categories/:id` | Admin JWT | Update category |

### Cart

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/cart/:userId` | Bearer token | Fetch cart |
| POST | `/cart/:userId/items` | Bearer token | Add item to cart |
| PUT | `/cart/:userId/items/:productId` | Bearer token | Set item quantity |
| DELETE | `/cart/:userId/items/:productId` | Bearer token | Remove item |
| DELETE | `/cart/:userId` | Bearer token | Clear cart |

### Checkout and Orders

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/checkout` | Bearer token | Place order |
| GET | `/orders` | Bearer token | List own orders; admin sees all |
| GET | `/orders/:id` | Bearer token | Order detail |

### Admin

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/admin/products` | Admin JWT | List products |
| POST | `/admin/products` | Admin JWT | Create product |
| PUT | `/admin/products/:id` | Admin JWT | Update product |
| PUT | `/admin/products/:id/stock` | Admin JWT | Set stock level |
| DELETE | `/admin/products/:id` | Admin JWT | Delete product |
| GET | `/admin/orders` | Admin JWT | List orders |
| GET | `/admin/orders/:id` | Admin JWT | Get order |
| PUT | `/admin/orders/:id` | Admin JWT | Update order status |
| GET | `/admin/users` | Admin JWT | List customers |
| GET | `/admin/users/:id` | Admin JWT | Get customer |

### Invoice

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/invoice/generate` | None | Generate invoice directly for local development/testing |

## Environment Variables

Each service has a `.env.example` file with its expected local configuration.

Common backend variables:

- `NODE_ENV`
- `PORT`
- `JWT_SECRET`

PostgreSQL services also use:

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`

AWS-backed local services also use:

- `AWS_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DYNAMODB_ENDPOINT`
- `DYNAMODB_TABLE`
- `SQS_ENDPOINT`
- `SQS_INVOICE_QUEUE_URL`
- `S3_ENDPOINT`
- `S3_BUCKET`
- `SES_FROM_EMAIL`

## Manual Database Commands

Docker Compose runs migrations and seeders automatically. To run them manually outside Compose:

```bash
cd project/database
npm install
npm run migrate
npm run seed
```

## Troubleshooting

### Docker build fails on `npm ci`

The service Dockerfiles use `npm ci`, which requires a committed `package-lock.json` in each package directory. If lockfiles are missing, run `npm install` in each service and in `database/`, then commit the generated lockfiles.

Directories that need lockfiles:

- `services/auth`
- `services/catalog`
- `services/cart`
- `services/checkout`
- `services/admin`
- `services/invoice`
- `database`

### Services start before dependencies are ready

PostgreSQL has a health check and the migration service waits for it. If a service fails during first startup, run:

```bash
docker compose down
docker compose up --build
```

## Infrastructure Scaffold

The `infrastructure/` directory currently contains placeholders for Terraform modules and monitoring assets:

```text
infrastructure/
  terraform/
    modules/
      alb/
      cloudfront/
      dynamodb/
      ecs/
      iam/
      rds/
      s3/
      vpc/
      waf/
    environments/
      dev/
      prod/
  monitoring/
    dashboards/
    alarms/
```

The `.github/workflows/` directory contains CI/CD workflow placeholders.

## Known Limitations

- Terraform modules are scaffolded but not implemented.
- GitHub Actions workflows are placeholders.
- Monitoring dashboards and alarms are placeholders.
- Automated tests are not yet included.
- No frontend UI is included.
- Invoice emails are notification emails only; the generated PDF is uploaded to S3 and is not attached to the SES email.
