import { API_URLS, authHeader, request } from './api';

export function getCart(userId, token) {
  return request(`${API_URLS.cart}/cart/${userId}`, {
    headers: authHeader(token),
  });
}

export function addCartItem(userId, token, product, quantity = 1) {
  return request(`${API_URLS.cart}/cart/${userId}/items`, {
    method: 'POST',
    headers: authHeader(token),
    body: JSON.stringify({
      productId: product.id,
      name: product.name,
      price: Number(product.price),
      quantity,
    }),
  });
}

export function updateCartItem(userId, token, productId, quantity) {
  return request(`${API_URLS.cart}/cart/${userId}/items/${productId}`, {
    method: 'PUT',
    headers: authHeader(token),
    body: JSON.stringify({ quantity: Number(quantity) }),
  });
}

export function removeCartItem(userId, token, productId) {
  return request(`${API_URLS.cart}/cart/${userId}/items/${productId}`, {
    method: 'DELETE',
    headers: authHeader(token),
  });
}
