import { useEffect, useState } from "react";
import axios from "axios";
import { API_URL } from "../config";
import { useParams } from 'react-router-dom';

const UserDetails = () => {
  const { id } = useParams();
  const [userDetails, setUserDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getUsers = async () => {
      try {
        const res = await axios.get(
          `${API_URL}/users/users/${id}/details`
        );
        if (!res.data) {
          setError("Belum ada detail");
        } else {
          setUserDetails(res.data);
          console.log(res.data);
        }
      } catch (error) {
        if (error.response && error.response.status === 404) {
          setError("Detail User Belum Ada");
        } else {
          setError(error.message); 
        }
      } finally {
        setLoading(false);
      }
    };
    getUsers();
  }, [id]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

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
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Phone Number</th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Image</th>
              </tr>
            </thead>
            <tbody>
              <tr className="text-sm dark:text-white">
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{userDetails.fullname || "-"}</td>
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{userDetails.email || "-"}</td>
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{userDetails.phone_number || "-"}</td>
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{userDetails.photo_profile || "-"}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
};

export default UserDetails;
