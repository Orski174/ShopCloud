import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { Trash2 } from 'lucide-react';
import { formatCurrency } from '../api/api';
import { getCart, removeCartItem, updateCartItem } from '../api/cart';

export default function Cart({ auth }) {
  const [cart, setCart] = useState({ items: [] });
  const [quantities, setQuantities] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [workingId, setWorkingId] = useState('');

  const items = cart.items || [];
  const total = useMemo(
    () => items.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0),
    [items]
  );

  async function loadCart() {
    setLoading(true);
    setError('');
    try {
      const data = await getCart(auth.user.id, auth.token);
      setCart(data);
      setQuantities(
        Object.fromEntries((data.items || []).map((item) => [item.productId, item.quantity]))
      );
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadCart();
  }, []);

  async function handleUpdate(productId) {
    setWorkingId(productId);
    setNotice('');
    try {
      const updated = await updateCartItem(auth.user.id, auth.token, productId, quantities[productId]);
      setCart(updated);
      setNotice('Cart quantity updated.');
    } catch (err) {
      setNotice(err.message);
    } finally {
      setWorkingId('');
    }
  }

  async function handleRemove(productId) {
    setWorkingId(productId);
    setNotice('');
    try {
      const updated = await removeCartItem(auth.user.id, auth.token, productId);
      setCart(updated);
      setNotice('Item removed from cart.');
    } catch (err) {
      setNotice(err.message);
    } finally {
      setWorkingId('');
    }
  }

  return (
    <section className="page narrow-page">
      <div className="section-heading">
        <div>
          <span className="eyebrow">Customer cart</span>
          <h1>Your Cart</h1>
          <p>Cart data is loaded from the cart service using your user id and JWT.</p>
        </div>
        <Link className="ghost-button" to="/">
          Continue shopping
        </Link>
      </div>

      {notice && <div className="notice">{notice}</div>}
      {loading && <div className="state-card">Loading cart...</div>}
      {error && <div className="state-card error-state">{error}</div>}
      {!loading && !error && items.length === 0 && (
        <div className="state-card">Your cart is empty. Browse the storefront to add products.</div>
      )}

      {!loading && !error && items.length > 0 && (
        <div className="cart-layout">
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Unit price</th>
                  <th>Quantity</th>
                  <th>Subtotal</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr key={item.productId}>
                    <td>
                      <strong>{item.name}</strong>
                      <small>{item.productId}</small>
                    </td>
                    <td>{formatCurrency(item.price)}</td>
                    <td>
                      <input
                        className="quantity-input"
                        type="number"
                        min="0"
                        value={quantities[item.productId] ?? item.quantity}
                        onChange={(event) =>
                          setQuantities({
                            ...quantities,
                            [item.productId]: event.target.value,
                          })
                        }
                      />
                    </td>
                    <td>{formatCurrency(Number(item.price) * Number(item.quantity))}</td>
                    <td className="row-actions">
                      <button
                        className="secondary-button"
                        type="button"
                        disabled={workingId === item.productId}
                        onClick={() => handleUpdate(item.productId)}
                      >
                        Update
                      </button>
                      <button
                        className="danger-button"
                        type="button"
                        disabled={workingId === item.productId}
                        onClick={() => handleRemove(item.productId)}
                        aria-label={`Remove ${item.name}`}
                      >
                        <Trash2 size={16} aria-hidden="true" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <aside className="summary-panel">
            <span className="eyebrow">Estimated total</span>
            <strong>{formatCurrency(total)}</strong>
            <p>Checkout will validate stock through the catalog service before creating the order.</p>
            <Link className="primary-button full-width center" to="/checkout">
              Proceed to checkout
            </Link>
          </aside>
        </div>
      )}
    </section>
  );
}
