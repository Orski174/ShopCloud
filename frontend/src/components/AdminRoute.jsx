import { Navigate, useLocation } from 'react-router-dom';

export default function AdminRoute({ adminToken, children }) {
  const location = useLocation();

  if (!adminToken) {
    return <Navigate to="/admin/login" replace state={{ from: location }} />;
  }

  return children;
}
