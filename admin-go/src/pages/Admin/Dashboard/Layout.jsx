import { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import { getMe } from "../../../features/authSlice";
import { HiUserGroup } from "react-icons/hi2";
import { RiUserForbidFill } from "react-icons/ri";
import { MdPending, MdDoneAll } from "react-icons/md";
import Card from "../../../components/ui/Card";
import axios from "axios";
import { API_URL } from "../../../config";
import CardTotalTopUp from "../../../components/CardTotalTopUp";
// import { format } from "date-fns";
// import { id } from "date-fns/locale";

const Layout = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { isError, user } = useSelector((state) => state.auth);
  // const [currentDate, setCurrentDate] = useState("");

  const [totalUsers, setTotalUsers] = useState(0);
  const [totalApprove, setTotalApprove] = useState(0);
  const [totalProduk, setTotalProduk] = useState(0);
  const [pesananPending, setPesananPending] = useState(0);

  // useEffect(() => {
  //   const formattedDate = format(new Date(), "EEE, dd MMM", { locale: id });
  //   setCurrentDate(formattedDate);
  // }, []);

  // Fetch total users from API
  useEffect(() => {
    const fetchTotalUsers = async () => {
      try {
        const res = await axios.get(`${API_URL}/users/total`);
        setTotalUsers(res.data.totalUser);
      } catch (error) {
        console.error("Failed to fetch total users:", error);
      }
    };

    const fetchTotalUserApproveFalse = async () => {
      try {
        const res = await axios.get(`${API_URL}/total/user-approve-false`);
        setTotalApprove(res.data.totalUserApproveFalse);
      } catch (error) {
        console.error("Failed to fetch total approve users:", error);
      }
    };

    const fetchTotalApprovedTopUp = async () => {
      try {
        const res = await axios.get(`${API_URL}/total/produk`);
        setTotalProduk(res.data.totalProduk);
      } catch (error) {
        console.error("Failed to fetch total users:", error);
      }
    };

    const fetchTotalPendingPesanan = async () => {
      try {
        const res = await axios.get(`${API_URL}/total/pesanan-pending`);
        setPesananPending(res.data.totalPesananPending);
      } catch (error) {
        console.error("Failed to fetch total users:", error);
      }
    };

    fetchTotalUsers();
    fetchTotalUserApproveFalse();
    fetchTotalApprovedTopUp();
    fetchTotalPendingPesanan();
  }, []);

  useEffect(() => {
    dispatch(getMe());
  }, [dispatch]);

  useEffect(() => {
    if (isError) {
      navigate("/");
    }
  }, [isError, navigate]);

  const currentDate = new Date().toLocaleDateString("en-US", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });

  return (
    <div>
      <div className="relative overflow-hidden mb-5">
        <div className="relative bg-white dark:bg-[#282828] backdrop-blur-sm rounded-2xl sm:rounded-3xl p-5 sm:p-6">
          {/* Header Section */}
          <div className="flex flex-col sm:flex-row items-start sm:items-start justify-between mb-4 sm:mb-6 space-y-4 sm:space-y-0">
            <div className="flex items-center space-x-3 sm:space-x-4">
              {/* Profile Avatar */}
              <div className="w-12 h-12 sm:w-14 sm:h-14 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl sm:rounded-2xl flex items-center justify-center shadow-lg flex-shrink-0">
                <span className="text-lg sm:text-xl font-bold text-white">
                  {user?.fullname
                    ?.split(" ")
                    .map((n) => n[0])
                    .join("") || "U"}
                </span>
              </div>

              <div className="min-w-0 flex-1">
                <h1 className="text-base sm:text-lg font-semibold text-slate-900 dark:text-white">
                  Welcome back,
                </h1>
                <h2 className="text-base sm:text-lg font-semibold bg-gradient-to-r from-indigo-600 via-purple-600 to-indigo-800 dark:from-indigo-400 dark:via-purple-400 dark:to-indigo-600 bg-clip-text text-transparent truncate">
                  {user?.fullname?.split(" ")[0] || "User"}
                </h2>
              </div>
            </div>

            {/* Date Badge */}
            <div className="flex flex-col items-start sm:items-end space-y-2 w-full sm:w-auto">
              <div className="px-3 py-1.5 sm:px-4 sm:py-2 bg-white dark:bg-[#3f3f3f] rounded-lg sm:rounded-xl border border-gray-200 dark:border-gray-500 w-full sm:w-auto">
                <span className="text-xs sm:text-sm font-semibold text-slate-600 dark:text-slate-300 block text-center sm:text-left">
                  {currentDate}
                </span>
              </div>
            </div>
          </div>

          {/* Status and Description */}
          <div className="space-y-3 sm:space-y-4">
            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-300 leading-relaxed max-w-full sm:max-w-2xl">
              Your productivity workspace is ready. Track your progress, manage
              tasks, and achieve your goals with precision and clarity.
            </p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <Card
          title="Registered Users"
          count={totalUsers}
          icon={<HiUserGroup />}
          iconColor="text-blue-500"
          to="/users"
        />
        <Card
          title="Unapproved Users"
          count={totalApprove}
          icon={<RiUserForbidFill />}
          iconColor="text-red-700"
          to="/users"
        />
        <Card
          title="Total Produk"
          count={totalProduk}
          icon={<MdDoneAll />}
          iconColor="text-green-500"
          to="/products"
        />
        <Card
          title="Pesanan Pending"
          count={pesananPending}
          icon={<MdPending />}
          iconColor="text-orange-500"
          to="/pesanan"
        />
      </div>

      <div className="mt-5">
        <CardTotalTopUp />
      </div>
    </div>
  );
};

export default Layout;
