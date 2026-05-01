import { API_URLS, authHeader, request } from './api';

export function registerCustomer({ name, email, password }) {
  return request(`${API_URLS.auth}/auth/register`, {
    method: 'POST',
    body: JSON.stringify({ name, email, password }),
  });
}

export function loginCustomer({ email, password }) {
  return request(`${API_URLS.auth}/auth/login`, {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
}

export function loginAdmin({ email, password }) {
  return request(`${API_URLS.auth}/auth/admin/login`, {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
}

export function getCurrentUser(token) {
  return request(`${API_URLS.auth}/auth/me`, {
    headers: authHeader(token),
  });
}
