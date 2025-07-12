import { useState, useEffect } from "react"
import axios from "axios"
import { Link } from "react-router-dom"
import { API_URL } from "../config";
import Swal from "sweetalert2";

const TransactionList = () => {
    const [users, setUsers] = useState([]);

  useEffect(() => {
    getUsers();
  }, []);

  const getUsers = async () => {
    const res = await axios.get(`${API_URL}/users/users`);
    setUsers(res.data);
    console.log(res.data);
  };

  const deleteUser = async (userId) => {
    await axios.delete(`${API_URL}/users/user/${userId}`);
    getUsers();

    Swal.fire({
      icon: "success",
      title: "Success",
      text: "User deleted successfully",
    });
  };

  return (
    <div>
      <h2 className="text-2xl font-semibold mb-4 dark:text-white">Transaction</h2>
      <div className="mt-5 overflow-x-auto bg-white rounded-xl p-4">
        {/* Tabel responsif */}
        <table className="table-auto w-full text-left text-black-100">
          <thead>
            <tr className="text-sm">
              <th className="px-4 py-2 border-b whitespace-nowrap">No</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Username</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Email</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Role</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user, index) => (
              <tr key={user.id} className="text-sm">
                <td className="px-4 py-2 border-b whitespace-nowrap">{index + 1}</td>
                <td className="px-4 py-2 border-b whitespace-nowrap">{user.username}</td>
                <td className="px-4 py-2 border-b whitespace-nowrap">{user.email}</td>
                <td className="px-4 py-2 border-b whitespace-nowrap">{user.role}</td>
                <td className="px-4 py-2 border-b whitespace-nowrap">
                  <Link
                    to={`/users/edit/${user.id}`}
                    className="bg-indigo-600 text-white rounded-md shadow hover:bg-indigo-700 focus:outline-none px-6 py-1 mr-2"
                  >
                    Edit
                  </Link>
                  <button
                    onClick={() => deleteUser(user.id)}
                    className=" bg-red-600 text-white rounded-md shadow hover:bg-red-700 focus:outline-none px-6 py-1"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

export default TransactionList