import Layout from "./Layout";
import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import { getMe } from "../../../features/authSlice";
import { getDashboardPathByRole } from "../../../utils/roleRoutes";

const DashboardKurir = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { isError, user } = useSelector((state) => state.auth);

 useEffect(() => {
  // Hanya panggil getMe jika user belum ada
  if (!user) {
    dispatch(getMe());
  }
}, [dispatch, user]);

  useEffect(() => {
    if (isError) {
      navigate("/");
    }
    if (user && user.role !== "kurir") {
      navigate(getDashboardPathByRole(user.role));
    }
  }, [isError, user, navigate]);

  return (
    <div>
      <Layout />
    </div>
  );
};

export default DashboardKurir;
