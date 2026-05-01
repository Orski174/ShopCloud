import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { registerCustomer } from '../api/auth';

export default function Register({ auth }) {
  const [form, setForm] = useState({ name: '', email: '', password: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  async function handleSubmit(event) {
    event.preventDefault();
    setLoading(true);
    setError('');
    try {
      const payload = await registerCustomer(form);
      auth.setCustomerSession(payload);
      navigate('/');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <section className="auth-page">
      <form className="form-card" onSubmit={handleSubmit}>
        <span className="eyebrow">Customer registration</span>
        <h1>Create account</h1>
        <p>Passwords must be at least 8 characters, matching the backend validator.</p>
        {error && <div className="form-error">{error}</div>}
        <label>
          Name
          <input
            value={form.name}
            onChange={(event) => setForm({ ...form, name: event.target.value })}
            required
          />
        </label>
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
            minLength={8}
            value={form.password}
            onChange={(event) => setForm({ ...form, password: event.target.value })}
            required
          />
        </label>
        <button className="primary-button full-width" type="submit" disabled={loading}>
          {loading ? 'Creating account...' : 'Register'}
        </button>
        <p className="form-footer">
          Already registered? <Link to="/login">Login</Link>
        </p>
      </form>
    </section>
  );
}
