# ShopCloud

A lightweight, cloud-native e-commerce platform built as a microservices application on Node.js/Express, designed for deployment on AWS ECS Fargate.

## Architecture

| Service | Port | Description | Data Store |
|---|---|---|---|
| **auth** | 3001 | Customer & admin authentication, JWT issuance | PostgreSQL |
| **catalog** | 3002 | Product listings, categories, search | PostgreSQL |
| **cart** | 3003 | Session-aware shopping cart with TTL | DynamoDB |
| **checkout** | 3004 | Order creation, stock validation, payment sim | PostgreSQL + SQS |
| **admin** | 3005 | Internal inventory & order management (internal-only) | PostgreSQL |
| **invoice** | 3006 | Async PDF invoice generation + email delivery | S3 + SES + SQS |

## Running locally

### Prerequisites
- Docker + Docker Compose

### Start all services

```bash
cd project/
docker compose up --build
```

This will start:
- PostgreSQL on port 5432
- DynamoDB Local on port 8000
- ElasticMQ (SQS-compatible) on port 9324
- LocalStack (S3 + SES) on port 4566
- All 6 microservices

Migrations and seeders run automatically on startup via the `migrations` service.

### Service endpoints

| Service | Base URL |
|---|---|
| auth | http://localhost:3001 |
| catalog | http://localhost:3002 |
| cart | http://localhost:3003 |
| checkout | http://localhost:3004 |
| admin | http://localhost:3005 |
| invoice | http://localhost:3006 |

All services expose `GET /health`.

## API Reference

### Auth (`/auth`)

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/register` | — | Register a new customer |
| POST | `/auth/login` | — | Customer login → JWT |
| POST | `/auth/admin/login` | — | Admin login → JWT |
| GET | `/auth/me` | Bearer token | Current user profile |
| POST | `/auth/logout` | — | Logout (stateless) |

### Catalog (`/products`, `/categories`)

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/products` | — | List products (supports `?q=`, `?category=`, `?page=`, `?limit=`) |
| GET | `/products/search?q=` | — | Search products |
| GET | `/products/:id` | — | Product detail |
| POST | `/products` | Admin JWT | Create product |
| PUT | `/products/:id` | Admin JWT | Update product |
| DELETE | `/products/:id` | Admin JWT | Delete product |
| GET | `/categories` | — | List all categories |
| GET | `/categories/:slug` | — | Category by slug |

### Cart (`/cart`)

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/cart/:userId` | Bearer token | Fetch cart |
| POST | `/cart/:userId/items` | Bearer token | Add item to cart |
| PUT | `/cart/:userId/items/:productId` | Bearer token | Set item quantity |
| DELETE | `/cart/:userId/items/:productId` | Bearer token | Remove item |
| DELETE | `/cart/:userId` | Bearer token | Clear cart |

### Checkout (`/checkout`, `/orders`)

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/checkout` | Bearer token | Place order (validates stock, creates order, publishes invoice job) |
| GET | `/orders` | Bearer token | List own orders (admin sees all) |
| GET | `/orders/:id` | Bearer token | Order detail |

### Admin (`/admin`) — internal only

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/admin/products` | Admin JWT | List all products |
| POST | `/admin/products` | Admin JWT | Create product |
| PUT | `/admin/products/:id` | Admin JWT | Update product |
| PUT | `/admin/products/:id/stock` | Admin JWT | Set stock level |
| DELETE | `/admin/products/:id` | Admin JWT | Delete product |
| GET | `/admin/orders` | Admin JWT | List all orders |
| PUT | `/admin/orders/:id` | Admin JWT | Update order status |
| GET | `/admin/users` | Admin JWT | List customers |

### Invoice (`/invoice`)

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/invoice/generate` | — | Generate invoice (dev/testing only) |

## Environment variables

Each service has a `.env.example` file in its directory. Copy it to `.env` and fill in values for local development outside Docker.

## Database

Migrations and seeders live in `database/`. Run them manually if needed:

```bash
cd database/
npm install
npm run migrate   # runs all migrations
npm run seed      # inserts sample categories and products
```

## Infrastructure

The `infrastructure/` directory contains the DevOps scaffold:

```
infrastructure/
├── terraform/
│   ├── modules/         # vpc, ecs, rds, dynamodb, s3, alb, cloudfront, waf, iam
│   └── environments/    # dev, prod
└── monitoring/
    ├── dashboards/
    └── alarms/
```

CI/CD workflow stubs are in `.github/workflows/`.
