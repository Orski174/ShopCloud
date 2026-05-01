import { useEffect, useState } from 'react';
import { formatCurrency, formatDate } from '../api/api';
import { listOrders } from '../api/checkout';

export default function Orders({ auth }) {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    async function loadOrders() {
      setLoading(true);
      setError('');
      try {
        const data = await listOrders(auth.token);
        setOrders(Array.isArray(data) ? data : []);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    loadOrders();
  }, [auth.token]);

  return (
    <section className="page narrow-page">
      <div className="section-heading">
        <div>
          <span className="eyebrow">Order history</span>
          <h1>Your Orders</h1>
          <p>Orders are loaded from the checkout service with your JWT.</p>
        </div>
      </div>

      {loading && <div className="state-card">Loading orders...</div>}
      {error && <div className="state-card error-state">{error}</div>}
      {!loading && !error && orders.length === 0 && (
        <div className="state-card">No orders yet. Place a checkout from your cart.</div>
      )}

      {!loading && !error && orders.length > 0 && (
        <div className="order-list">
          {orders.map((order) => (
            <article className="order-card" key={order.id}>
              <div>
                <span className="eyebrow">Order ID</span>
                <h2>{order.id}</h2>
                <p>{formatDate(order.createdAt || order.created_at)}</p>
              </div>
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
            </article>
          ))}
        </div>
      )}
    </section>
  );
}
