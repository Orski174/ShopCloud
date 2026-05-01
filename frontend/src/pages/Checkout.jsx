import { useState } from 'react';
import { Link } from 'react-router-dom';
import { formatCurrency } from '../api/api';
import { placeOrder } from '../api/checkout';

export default function Checkout({ auth }) {
  const [shipping, setShipping] = useState({ line1: '', city: '', country: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [order, setOrder] = useState(null);

  async function handleSubmit(event) {
    event.preventDefault();
    setLoading(true);
    setError('');
    setOrder(null);
    try {
      const created = await placeOrder(auth.token, shipping);
      setOrder(created);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <section className="page narrow-page">
      <div className="section-heading">
        <div>
          <span className="eyebrow">Order placement</span>
          <h1>Checkout</h1>
          <p>The request body is sent as the backend expects: a `shipping_address` object.</p>
        </div>
      </div>

      <div className="checkout-grid">
        <form className="form-card inline-form" onSubmit={handleSubmit}>
          <label>
            Address line
            <input
              value={shipping.line1}
              onChange={(event) => setShipping({ ...shipping, line1: event.target.value })}
              required
            />
          </label>
          <label>
            City
            <input
              value={shipping.city}
              onChange={(event) => setShipping({ ...shipping, city: event.target.value })}
              required
            />
          </label>
          <label>
            Country
            <input
              value={shipping.country}
              onChange={(event) => setShipping({ ...shipping, country: event.target.value })}
              required
            />
          </label>
          {error && <div className="form-error">{error}</div>}
          <button className="primary-button full-width" type="submit" disabled={loading}>
            {loading ? 'Placing order...' : 'Place order'}
          </button>
        </form>

        <aside className="summary-panel">
          <span className="eyebrow">Invoice behavior</span>
          <p>
            After checkout succeeds, the backend publishes an invoice job. The invoice worker
            generates a PDF asynchronously and uploads it to S3 or LocalStack.
          </p>
        </aside>
      </div>

      {order && (
        <div className="confirmation-panel">
          <span className="eyebrow">Order confirmed</span>
          <h2>Order {order.id}</h2>
          <dl className="detail-grid">
            <div>
              <dt>Status</dt>
              <dd>{order.status}</dd>
            </div>
            <div>
              <dt>Payment</dt>
              <dd>{order.payment_status}</dd>
            </div>
            <div>
              <dt>Total</dt>
              <dd>{formatCurrency(order.total_amount)}</dd>
            </div>
            <div>
              <dt>Items</dt>
              <dd>{order.items?.length || 0}</dd>
            </div>
          </dl>
          <Link className="primary-button" to="/orders">
            View orders
          </Link>
        </div>
      )}
    </section>
  );
}
