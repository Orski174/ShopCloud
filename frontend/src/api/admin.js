import { API_URLS, authHeader, request } from './api';

export function listAdminProducts(adminToken) {
  return request(`${API_URLS.admin}/admin/products`, {
    headers: authHeader(adminToken),
  });
}

export function listAdminOrders(adminToken) {
  return request(`${API_URLS.admin}/admin/orders`, {
    headers: authHeader(adminToken),
  });
}

export function updateProductStock(adminToken, productId, stockQuantity) {
  return request(`${API_URLS.admin}/admin/products/${productId}/stock`, {
    method: 'PUT',
    headers: authHeader(adminToken),
    body: JSON.stringify({ stock_quantity: Number(stockQuantity) }),
  });
}
