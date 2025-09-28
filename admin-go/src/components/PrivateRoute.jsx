import { useEffect } from "react";
import { useSelector } from "react-redux";
import { useNavigate, Outlet } from "react-router-dom";

const PrivateRoute = ({ roles = [] }) => {
  const { user, isLoading } = useSelector((state) => state.auth);
  const navigate = useNavigate();

  useEffect(() => {
    // Redirect jika tidak loading dan tidak ada user
    if (!isLoading && !user) {
      navigate("/");
    }

    // Redirect jika user ada tapi rolenya tidak diizinkan
    if (user && roles.length > 0 && !roles.includes(user.role)) {
      navigate("/unauthorized");
    }
  }, [user, isLoading, roles, navigate]);

  // Tampilkan loading indicator selama proses autentikasi
  if (isLoading || !user) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-[#74B11A]"></div>
      </div>
    );
  }

  // Render children jika terautentikasi
  return <Outlet />;
};

export default PrivateRoute;