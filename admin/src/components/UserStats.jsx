import { useEffect, useState } from "react";
import axios from "axios";
import { API_URL } from "../config";
import { useParams } from "react-router-dom";
import { formatDate } from "../utils/formateDate";

const UserStats = () => {
  const { id } = useParams();
  const [userStats, setUserStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getStats = async () => {
      try {
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
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

  // Memastikan last_login valid sebelum diproses
  const formattedLastLogin = userStats?.last_login
    ? formatDate(userStats.last_login)
    : "-";

  return (
    <>
      <div>
        <h2 className="text-2xl font-semibold mb-4 dark:text-white">User Detail</h2>
        <div className="mt-5 overflow-x-auto bg-white dark:bg-[#282828] rounded-xl p-4">
          <table className="table-auto w-full text-left text-black-100">
            <thead>
              <tr className="text-sm dark:text-white">
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Fullname</th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Email</th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Last Login</th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Total Login</th>
              </tr>
            </thead>
            <tbody>
              <tr className="text-sm dark:text-white">
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{userStats.fullname}</td>
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{userStats.email}</td>
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{formattedLastLogin}</td>
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  {userStats.total_logins || "-"}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
};

export default UserStats;
