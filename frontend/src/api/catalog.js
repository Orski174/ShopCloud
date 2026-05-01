import { API_URLS, request } from './api';

export function listProducts(params = {}) {
  const search = new URLSearchParams(params);
  const query = search.toString();
  return request(`${API_URLS.catalog}/products${query ? `?${query}` : ''}`);
}

export function searchProducts(query) {
  const search = new URLSearchParams({ q: query });
  return request(`${API_URLS.catalog}/products/search?${search.toString()}`);
}

export function listCategories() {
  return request(`${API_URLS.catalog}/categories`);
}
