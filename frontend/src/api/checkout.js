import { API_URLS, authHeader, request } from './api';

export function placeOrder(token, shippingAddress) {
  return request(`${API_URLS.checkout}/checkout`, {
    method: 'POST',
    headers: authHeader(token),
    body: JSON.stringify({
      shipping_address: shippingAddress,
    }),
  });
}

export function listOrders(token) {
  return request(`${API_URLS.checkout}/orders`, {
    headers: authHeader(token),
  });
}
