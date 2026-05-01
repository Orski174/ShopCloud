import { useEffect, useMemo, useState } from 'react';
import { RefreshCw } from 'lucide-react';
import { formatCurrency, formatDate } from '../api/api';
import { listAdminOrders, listAdminProducts, updateProductStock } from '../api/admin';

export default function AdminDashboard({ auth }) {
  const [products, setProducts] = useState([]);
  const [orders, setOrders] = useState([]);
  const [stockDrafts, setStockDrafts] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [savingId, setSavingId] = useState('');

  const metrics = useMemo(
    () => ({
      products: products.length,
      orders: orders.length,
      openOrders: orders.filter((order) => !['delivered', 'cancelled'].includes(order.status)).length,
    }),
    [orders, products]
  );

  async function loadDashboard() {
    setLoading(true);
    setError('');
    try {
      const [productData, orderData] = await Promise.all([
        listAdminProducts(auth.adminToken),
        listAdminOrders(auth.adminToken),
      ]);
      const productRows = productData.products || [];
      const orderRows = orderData.orders || [];
      setProducts(productRows);
      setOrders(orderRows);
      setStockDrafts(
        Object.fromEntries(productRows.map((product) => [product.id, product.stock_quantity]))
      );
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadDashboard();
  }, []);

  async function handleStockSave(productId) {
    setSavingId(productId);
    setNotice('');
    try {
      const result = await updateProductStock(auth.adminToken, productId, stockDrafts[productId]);
      setProducts((current) =>
        current.map((product) =>
          product.id === productId
            ? { ...product, stock_quantity: result.stock_quantity }
            : product
        )
      );
      setNotice('Stock quantity updated.');
    } catch (err) {
      setNotice(err.message);
    } finally {
      setSavingId('');
    }
  }

  return (
    <section className="page admin-page">
      <div className="section-heading">
        <div>
          <span className="eyebrow">Admin dashboard</span>
          <h1>Operations Overview</h1>
          <p>Admin data is loaded from the implemented admin service endpoints.</p>
        </div>
        <button className="ghost-button" type="button" onClick={loadDashboard}>
          <RefreshCw size={16} aria-hidden="true" />
          Refresh
        </button>
      </div>

      {notice && <div className="notice">{notice}</div>}
      {loading && <div className="state-card">Loading admin dashboard...</div>}
      {error && <div className="state-card error-state">{error}</div>}

      {!loading && !error && (
        <>
          <div className="metric-row">
            <div className="metric-card">
              <span>Products</span>
              <strong>{metrics.products}</strong>
            </div>
            <div className="metric-card">
              <span>Orders</span>
              <strong>{metrics.orders}</strong>
            </div>
            <div className="metric-card">
              <span>Active orders</span>
              <strong>{metrics.openOrders}</strong>
            </div>
          </div>

          <section className="dashboard-section">
            <div className="section-heading compact-heading">
              <div>
                <h2>Products</h2>
                <p>Stock update uses `PUT /admin/products/:id/stock`.</p>
              </div>
            </div>
            {products.length === 0 ? (
              <div className="state-card">No products returned by the admin service.</div>
            ) : (
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Price</th>
                      <th>Stock quantity</th>
                      <th>Category</th>
                      <th>Update stock</th>
                    </tr>
                  </thead>
                  <tbody>
                    {products.map((product) => (
                      <tr key={product.id}>
                        <td>
                          <strong>{product.name}</strong>
                          <small>{product.id}</small>
                        </td>
                        <td>{formatCurrency(product.price)}</td>
                        <td>{product.stock_quantity}</td>
                        <td>{product.category?.name || 'Uncategorized'}</td>
                        <td className="stock-editor">
                          <input
                            type="number"
                            min="0"
                            value={stockDrafts[product.id] ?? product.stock_quantity}
                            onChange={(event) =>
                              setStockDrafts({
                                ...stockDrafts,
                                [product.id]: event.target.value,
                              })
                            }
                          />
                          <button
                            className="secondary-button"
                            type="button"
                            disabled={savingId === product.id}
                            onClick={() => handleStockSave(product.id)}
                          >
                            Save
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>

          <section className="dashboard-section">
            <div className="section-heading compact-heading">
              <div>
                <h2>Orders</h2>
                <p>Order rows come from `GET /admin/orders`.</p>
              </div>
            </div>
            {orders.length === 0 ? (
              <div className="state-card">No orders returned by the admin service.</div>
            ) : (
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Order id</th>
                      <th>User id</th>
                      <th>Status</th>
                      <th>Payment</th>
                      <th>Total</th>
                      <th>Created</th>
                    </tr>
                  </thead>
                  <tbody>
                    {orders.map((order) => (
                      <tr key={order.id}>
                        <td>
                          <strong>{order.id}</strong>
                        </td>
                        <td>{order.user_id}</td>
                        <td><span className="status-pill">{order.status}</span></td>
                        <td>{order.payment_status}</td>
                        <td>{formatCurrency(order.total_amount)}</td>
                        <td>{formatDate(order.createdAt || order.created_at)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>
        </>
      )}
    </section>
  );
}
