import { useEffect, useState } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import { useParams } from "react-router-dom";
import { formatDate } from "../../../utils/formateDate";
import { BiStats } from "react-icons/bi";
import Button from "../../../components/ui/Button";
import { MdKeyboardArrowLeft } from "react-icons/md";

const Layout = () => {
  const { id } = useParams();
  const [userStats, setUserStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getStats = async () => {
      try {
        setLoading(true);
        const res = await axios.get(`${API_URL}/user-stats/${id}/stats`);
        setUserStats(res.data);
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };
    getStats();
  }, [id]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-500"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4">
        <p className="text-red-600 dark:text-red-400 text-sm font-medium">
          {error}
        </p>
      </div>
    );
  }

  const formattedLastLogin = userStats?.last_login
    ? formatDate(userStats.last_login)
    : "-";

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
            <BiStats className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              User Statistics
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Detailed statistics and activity for user
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <Button
            text="Back to Users"
            to="/users"
            iconPosition="left"
            icon={<MdKeyboardArrowLeft />}
            className="bg-blue-500 hover:bg-blue-600"
          />
        </div>
      </div>

      {/* Stats Table Section */}
      <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-gray-50 dark:bg-[#252525] border-b border-gray-200 dark:border-[#2a2a2a]">
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                 Fullname
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Email Address
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Last Login
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Total Login
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
              <tr className="hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150">
                <td className="py-4 px-6 whitespace-nowrap">
                  <div className="flex items-center gap-3">
                    <div className="text-sm font-medium text-gray-900 dark:text-white">
                      {userStats.fullname || "No Name"}
                    </div>
                  </div>
                </td>
                <td className="py-4 px-6 whitespace-nowrap">
                  <div className="text-sm text-gray-900 dark:text-white font-medium">
                    {userStats.email}
                  </div>
                </td>
                <td className="py-4 px-6 whitespace-nowrap">
                  <div className="text-sm text-gray-900 dark:text-white font-medium">
                    {formattedLastLogin}
                  </div>
                </td>
                <td className="py-4 px-6 whitespace-nowrap">
                  <div className="text-sm text-gray-900 dark:text-white font-medium">
                    {userStats.total_logins || "0"}
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Layout;
