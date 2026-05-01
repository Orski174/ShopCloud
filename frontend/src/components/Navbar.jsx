import { Link, NavLink } from 'react-router-dom';
import { LogIn, LogOut, PackageSearch, Shield, ShoppingBag, ShoppingCart } from 'lucide-react';

export default function Navbar({ auth }) {
  const isLoggedIn = Boolean(auth.token && auth.user);
  const isAdmin = Boolean(auth.adminToken);

  return (
    <header className="site-header">
      <Link className="brand" to="/" aria-label="ShopCloud home">
        <span className="brand-mark">SC</span>
        <span>
          <strong>ShopCloud</strong>
          <small>DevOps Commerce</small>
        </span>
      </Link>

      <nav className="nav-links" aria-label="Main navigation">
        <NavLink to="/" className={({ isActive }) => (isActive ? 'active' : '')}>
          <ShoppingBag size={17} aria-hidden="true" />
          Home
        </NavLink>
        <NavLink to="/cart" className={({ isActive }) => (isActive ? 'active' : '')}>
          <ShoppingCart size={17} aria-hidden="true" />
          Cart
        </NavLink>
        <NavLink to="/orders" className={({ isActive }) => (isActive ? 'active' : '')}>
          <PackageSearch size={17} aria-hidden="true" />
          Orders
        </NavLink>
        <NavLink to="/admin/login" className={({ isActive }) => (isActive ? 'active' : '')}>
          <Shield size={17} aria-hidden="true" />
          Admin Login
        </NavLink>
        {isAdmin && (
          <NavLink to="/admin" className={({ isActive }) => (isActive ? 'active' : '')}>
            Dashboard
          </NavLink>
        )}
      </nav>

      <div className="session-area">
        {isLoggedIn ? (
          <span className="user-pill" title={auth.user.email}>
            {auth.user.email}
          </span>
        ) : (
          <div className="auth-actions">
            <Link className="ghost-button" to="/login">
              <LogIn size={16} aria-hidden="true" />
              Login
            </Link>
            <Link className="primary-button compact" to="/register">
              Register
            </Link>
          </div>
        )}
        {(isLoggedIn || isAdmin) && (
          <button className="icon-text-button" type="button" onClick={auth.logout}>
            <LogOut size={16} aria-hidden="true" />
            Logout
          </button>
        )}
      </div>
    </header>
  );
}
