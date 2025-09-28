// components/ProtectedRoute.jsx
import { useSelector } from "react-redux";
import { Navigate, Outlet, useLocation } from "react-router-dom";

const ProtectedRoute = ({ allowedRoles, children }) => {
  const { user, isLoading, isError, isSuccess } = useSelector((state) => state.auth);
  const location = useLocation();

  // Jika masih loading, tampilkan loading indicator
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500"></div>
      </div>
    );
  }

  // Jika ada error atau tidak ada user setelah proses login selesai
  if (isError || (!user && !isLoading && isSuccess)) {
    return <Navigate to="/" replace />;
  }

  // Jika user ada tapi belum diverifikasi
  if (!user) {
    return <Navigate to="/" state={{ from: location }} replace />;
  }

  // Cek role
  if (allowedRoles.includes(user.role)) {
    return children ? children : <Outlet />;
  }

  return <Navigate to="/unauthorized" replace />;
};

export default ProtectedRoute;