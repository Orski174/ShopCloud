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
