import { useEffect, useMemo, useState } from 'react';
import { Search } from 'lucide-react';
import { addCartItem } from '../api/cart';
import { listProducts, searchProducts } from '../api/catalog';
import ProductCard from '../components/ProductCard.jsx';

export default function Home({ auth }) {
  const [products, setProducts] = useState([]);
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [addingId, setAddingId] = useState('');

  const productCount = useMemo(() => products.length, [products]);

  async function loadProducts(searchTerm = '') {
    setLoading(true);
    setError('');
    try {
      const data = searchTerm.trim()
        ? await searchProducts(searchTerm.trim())
        : await listProducts({ limit: 50 });
      setProducts(data.products || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadProducts();
  }, []);

  async function handleSearch(event) {
    event.preventDefault();
    await loadProducts(query);
  }

  async function handleAddToCart(product) {
    setNotice('');
    if (!auth.token || !auth.user?.id) {
      setNotice('Please log in before adding products to your cart.');
      return;
    }

    setAddingId(product.id);
    try {
      await addCartItem(auth.user.id, auth.token, product, 1);
      setNotice(`${product.name} was added to your cart.`);
    } catch (err) {
      setNotice(err.message);
    } finally {
      setAddingId('');
    }
  }

  return (
    <section className="page">
      <div className="store-hero">
        <div>
          <span className="eyebrow">AUB-inspired cloud commerce demo</span>
          <h1>ShopCloud</h1>
          <p>
            A clean storefront for the implemented microservice backend: catalog, carts,
            checkout, orders, and asynchronous invoices.
          </p>
        </div>
        <form className="search-panel" onSubmit={handleSearch}>
          <label htmlFor="search">Search products</label>
          <div className="search-row">
            <input
              id="search"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Headphones, books, keyboard..."
            />
            <button className="primary-button" type="submit">
              <Search size={17} aria-hidden="true" />
              Search
            </button>
          </div>
          <button className="link-button" type="button" onClick={() => { setQuery(''); loadProducts(); }}>
            Reset catalog
          </button>
        </form>
      </div>

      <div className="section-heading">
        <div>
          <h2>Products</h2>
          <p>{productCount} item{productCount === 1 ? '' : 's'} available from the catalog service.</p>
        </div>
        {!auth.token && <span className="soft-badge">Login required to add to cart</span>}
      </div>

      {notice && <div className="notice">{notice}</div>}
      {loading && <div className="state-card">Loading products...</div>}
      {error && <div className="state-card error-state">{error}</div>}
      {!loading && !error && products.length === 0 && (
        <div className="state-card">No products matched this search.</div>
      )}

      {!loading && !error && products.length > 0 && (
        <div className="product-grid">
          {products.map((product) => (
            <ProductCard
              key={product.id}
              product={product}
              onAddToCart={handleAddToCart}
              disabled={addingId === product.id}
            />
          ))}
        </div>
      )}
    </section>
  );
}
