import { useEffect, useMemo, useState } from 'react';
import { Navigate, Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import Navbar from './components/Navbar.jsx';
import ProtectedRoute from './components/ProtectedRoute.jsx';
import AdminRoute from './components/AdminRoute.jsx';
import Home from './pages/Home.jsx';
import Login from './pages/Login.jsx';
import Register from './pages/Register.jsx';
import Cart from './pages/Cart.jsx';
import Checkout from './pages/Checkout.jsx';
import Orders from './pages/Orders.jsx';
import AdminLogin from './pages/AdminLogin.jsx';
import AdminDashboard from './pages/AdminDashboard.jsx';

const CUSTOMER_TOKEN_KEY = 'shopcloud_token';
const CUSTOMER_USER_KEY = 'shopcloud_user';
const ADMIN_TOKEN_KEY = 'shopcloud_admin_token';
const ADMIN_USER_KEY = 'shopcloud_admin_user';

function readJson(key) {
  try {
    const value = localStorage.getItem(key);
    return value ? JSON.parse(value) : null;
  } catch {
    return null;
  }
}

export default function App() {
  const [token, setToken] = useState(() => localStorage.getItem(CUSTOMER_TOKEN_KEY));
  const [user, setUser] = useState(() => readJson(CUSTOMER_USER_KEY));
  const [adminToken, setAdminToken] = useState(() => localStorage.getItem(ADMIN_TOKEN_KEY));
  const [adminUser, setAdminUser] = useState(() => readJson(ADMIN_USER_KEY));
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    if (token) localStorage.setItem(CUSTOMER_TOKEN_KEY, token);
    else localStorage.removeItem(CUSTOMER_TOKEN_KEY);
  }, [token]);

  useEffect(() => {
    if (user) localStorage.setItem(CUSTOMER_USER_KEY, JSON.stringify(user));
    else localStorage.removeItem(CUSTOMER_USER_KEY);
  }, [user]);

  useEffect(() => {
    if (adminToken) localStorage.setItem(ADMIN_TOKEN_KEY, adminToken);
    else localStorage.removeItem(ADMIN_TOKEN_KEY);
  }, [adminToken]);

  useEffect(() => {
    if (adminUser) localStorage.setItem(ADMIN_USER_KEY, JSON.stringify(adminUser));
    else localStorage.removeItem(ADMIN_USER_KEY);
  }, [adminUser]);

  const auth = useMemo(
    () => ({
      token,
      user,
      adminToken,
      adminUser,
      setCustomerSession(payload) {
        setToken(payload.token);
        setUser(payload.user);
      },
      setAdminSession(payload) {
        setAdminToken(payload.token);
        setAdminUser(payload.user);
      },
      logout() {
        setToken(null);
        setUser(null);
        setAdminToken(null);
        setAdminUser(null);
        if (location.pathname !== '/') navigate('/');
      },
    }),
    [adminToken, adminUser, location.pathname, navigate, token, user]
  );

  return (
    <div className="app-shell">
      <Navbar auth={auth} />
      <main>
        <Routes>
          <Route path="/" element={<Home auth={auth} />} />
          <Route path="/login" element={<Login auth={auth} />} />
          <Route path="/register" element={<Register auth={auth} />} />
          <Route
            path="/cart"
            element={
              <ProtectedRoute token={token}>
                <Cart auth={auth} />
              </ProtectedRoute>
            }
          />
          <Route
            path="/checkout"
            element={
              <ProtectedRoute token={token}>
                <Checkout auth={auth} />
              </ProtectedRoute>
            }
          />
          <Route
            path="/orders"
            element={
              <ProtectedRoute token={token}>
                <Orders auth={auth} />
              </ProtectedRoute>
            }
          />
          <Route path="/admin/login" element={<AdminLogin auth={auth} />} />
          <Route
            path="/admin"
            element={
              <AdminRoute adminToken={adminToken}>
                <AdminDashboard auth={auth} />
              </AdminRoute>
            }
          />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
    </div>
  );
}
