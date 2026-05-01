import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { loginAdmin } from '../api/auth';

export default function AdminLogin({ auth }) {
  const [form, setForm] = useState({ email: 'admin@shopcloud.com', password: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const location = useLocation();

  async function handleSubmit(event) {
    event.preventDefault();
    setLoading(true);
    setError('');
    try {
      const payload = await loginAdmin(form);
      auth.setAdminSession(payload);
      navigate(location.state?.from?.pathname || '/admin');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <section className="auth-page">
      <form className="form-card" onSubmit={handleSubmit}>
        <span className="eyebrow">Internal API access</span>
        <h1>Admin Login</h1>
        <p>Seeded demo email is prefilled. Use the seeded password from the database seeder.</p>
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
          {loading ? 'Signing in...' : 'Login as admin'}
        </button>
      </form>
    </section>
  );
}
