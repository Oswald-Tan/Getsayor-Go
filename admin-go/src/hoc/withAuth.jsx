import { useEffect, useCallback } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import { getMe } from "../features/authSlice";
import { getDashboardPathByRole } from "../utils/roleRoutes";

const withAuth = (allowedRoles = []) => (WrappedComponent) => {
  const ComponentWithAuth = (props) => {
    const dispatch = useDispatch();
    const navigate = useNavigate();
    const { user, isError, isLoading } = useSelector((state) => state.auth);

    // Fungsi untuk memeriksa otorisasi
    const checkAuth = useCallback(() => {
      if (isError) {
        navigate("/");
        return;
      }
      
      if (user) {
        const isAllowed = allowedRoles.includes(user.role);
        if (!isAllowed) {
          const path = getDashboardPathByRole(user.role);
          navigate(path);
        }
      }
    }, [user, isError, navigate, allowedRoles]);

    useEffect(() => {
      if (!user && !isLoading) {
        dispatch(getMe());
      }
    }, [dispatch, user, isLoading]);

    useEffect(() => {
      checkAuth();
    }, [checkAuth]);

    // Tampilkan loading hanya jika sedang memuat dan belum ada user
    if (isLoading || !user) {
      return (
        <div className="min-h-screen flex items-center justify-center">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-[#74B11A]"></div>
        </div>
      );
    }

    return <WrappedComponent {...props} />;
  };

  ComponentWithAuth.displayName = `withAuth(${WrappedComponent.displayName || WrappedComponent.name || 'Component'})`;
  
  return ComponentWithAuth;
};

export default withAuth;