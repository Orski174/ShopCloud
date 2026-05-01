import { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { loginCustomer } from '../api/auth';

export default function Login({ auth }) {
  const [form, setForm] = useState({ email: '', password: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const location = useLocation();

  async function handleSubmit(event) {
    event.preventDefault();
    setLoading(true);
    setError('');
    try {
      const payload = await loginCustomer(form);
      auth.setCustomerSession(payload);
      navigate(location.state?.from?.pathname || '/');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <section className="auth-page">
      <form className="form-card" onSubmit={handleSubmit}>
        <span className="eyebrow">Customer access</span>
        <h1>Login</h1>
        <p>Use the customer account created through the auth service.</p>
        {error && <div className="form-error">{error}</div>}
        <label>
          Email
          <input
            type="email"
            value={form.email}
            onChange={(event) => setForm({ ...form, email: event.target.value })}
            required
          />
        </label>
        <label>
          Password
          <input
            type="password"
            value={form.password}
            onChange={(event) => setForm({ ...form, password: event.target.value })}
            required
          />
        </label>
        <button className="primary-button full-width" type="submit" disabled={loading}>
          {loading ? 'Signing in...' : 'Login'}
        </button>
        <p className="form-footer">
          New to ShopCloud? <Link to="/register">Create an account</Link>
        </p>
      </form>
    </section>
  );
}
