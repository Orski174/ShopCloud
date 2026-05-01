export const API_URLS = {
  auth: import.meta.env.VITE_AUTH_API_URL || 'http://localhost:3001',
  catalog: import.meta.env.VITE_CATALOG_API_URL || 'http://localhost:3002',
  cart: import.meta.env.VITE_CART_API_URL || 'http://localhost:3003',
  checkout: import.meta.env.VITE_CHECKOUT_API_URL || 'http://localhost:3004',
  admin: import.meta.env.VITE_ADMIN_API_URL || 'http://localhost:3005',
  invoice: import.meta.env.VITE_INVOICE_API_URL || 'http://localhost:3006',
};

export function authHeader(token) {
  return token ? { Authorization: `Bearer ${token}` } : {};
}

export function formatCurrency(value) {
  const numberValue = Number(value || 0);
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(Number.isFinite(numberValue) ? numberValue : 0);
}

export function formatDate(value) {
  if (!value) return 'Not available';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return 'Not available';
  return new Intl.DateTimeFormat('en-US', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(date);
}

export async function request(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...(options.headers || {}),
    },
  });

  const contentType = response.headers.get('content-type') || '';
  const payload = contentType.includes('application/json')
    ? await response.json()
    : await response.text();

  if (!response.ok) {
    const detail = Array.isArray(payload?.errors)
      ? payload.errors.map((error) => error.msg).join(', ')
      : payload?.error || payload?.message || payload || 'Request failed';
    throw new Error(detail);
  }

  return payload;
}
