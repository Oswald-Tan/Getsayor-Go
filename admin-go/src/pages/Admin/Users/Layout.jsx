import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import Button from "../../../components/ui/Button";
import ButtonAction from "../../../components/ui/ButtonAction";
import { RiApps2AddFill, RiCoinFill } from "react-icons/ri";
import {
  MdEditSquare,
  MdDelete,
  MdSearch,
  MdKeyboardArrowDown,
  MdDeleteForever,
} from "react-icons/md";
import { GrPowerReset } from "react-icons/gr";
import { BiSolidUserDetail, BiStats } from "react-icons/bi";
import { FaUserCheck, FaUsers } from "react-icons/fa6";
import { HiOutlineUsers } from "react-icons/hi2";
import ReactPaginate from "react-paginate";

const Layout = () => {
  const [users, setUsers] = useState([]);
  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [message, setMessage] = useState("");
  const [pages, setPages] = useState(0);
  const [rows, setRows] = useState(0);
  const [keyword, setKeyword] = useState("");
  const [query, setQuery] = useState("");
  const [typingTimeout, setTypingTimeout] = useState(null);
  const [loading, setLoading] = useState(false);

  const changePage = ({ selected }) => {
    setPage(selected);
    setMessage("");
  };

  const searchData = (e) => {
    e.preventDefault();
    setPage(0);
    setMessage("");
    setKeyword(query);
  };

  useEffect(() => {
    getUsers();
  }, [page, keyword, limit]);

  useEffect(() => {
    if (typingTimeout) {
      clearTimeout(typingTimeout);
    }
    const timeout = setTimeout(() => {
      setKeyword(query);
    }, 300);

    setTypingTimeout(timeout);
    return () => clearTimeout(timeout);
  }, [query]);

  const getUsers = async () => {
    setLoading(true);
    try {
      const res = await axios.get(
        `${API_URL}/users?search=${keyword}&page=${page}&limit=${limit}`
      );

      if (res.data && res.data.data) {
        setUsers(res.data.data || 0);
        setPages(res.data.totalPages || 0);
        setRows(res.data.totalRows || 0);
        setPage(res.data.page || 0);
      } else {
        console.error("Invalid response structure", res);
      }

      if (res.data.data.length === 0 && page > 0) {
        setPage(0);
      }
    } catch (error) {
      Swal.fire("Error!", error.message, "error");
    } finally {
      setLoading(false);
    }
  };

  const handleReset = async (id) => {
    Swal.fire({
      title: "Apakah Anda yakin?",
      text: "Password akan direset ke default!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Ya, reset!",
      customClass: {
        popup: "rounded-xl",
        confirmButton: "rounded-lg",
        cancelButton: "rounded-lg",
      },
    }).then(async (result) => {
      if (result.isConfirmed) {
        try {
          await axios.put(`${API_URL}/auth-web/update-pass/${id}`);
          Swal.fire("Berhasil!", "Password telah direset.", "success");
        } catch (error) {
          Swal.fire(
            "Error!",
            error.response?.data?.message || "Terjadi kesalahan",
            "error"
          );
        }
      }
    });
  };

  const deleteUser = async (userId) => {
    Swal.fire({
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc2626",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Yes, delete it!",
      customClass: {
        popup: "rounded-xl",
        confirmButton: "rounded-lg",
        cancelButton: "rounded-lg",
      },
    }).then(async (result) => {
      if (result.isConfirmed) {
        await axios.delete(`${API_URL}/users/${userId}`);
        getUsers();

        Swal.fire({
          icon: "success",
          title: "Deleted!",
          text: "User deleted successfully.",
          customClass: {
            popup: "rounded-xl",
            confirmButton: "rounded-lg",
          },
        });
      }
    });
  };

  const getRoleBadge = (role) => {
    const roleConfig = {
      admin: {
        color:
          "bg-gradient-to-r from-orange-100 to-orange-200 text-orange-800 border-orange-300",
        darkColor:
          "dark:from-orange-900/30 dark:to-orange-800/30 dark:text-orange-300 dark:border-orange-700",
      },
      user: {
        color:
          "bg-gradient-to-r from-green-100 to-green-200 text-green-800 border-green-300",
        darkColor:
          "dark:from-green-900/30 dark:to-green-800/30 dark:text-green-300 dark:border-green-700",
      },
      delivery: {
        color:
          "bg-gradient-to-r from-blue-100 to-blue-200 text-blue-800 border-blue-300",
        darkColor:
          "dark:from-blue-900/30 dark:to-blue-800/30 dark:text-blue-300 dark:border-blue-700",
      },
    };

    const config = roleConfig[role] || roleConfig.user;

    return (
      <span
        className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold border ${config.color} ${config.darkColor} transition-all duration-200`}
      >
        {role.charAt(0).toUpperCase() + role.slice(1)}
      </span>
    );
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
            <HiOutlineUsers className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              User Management
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Manage and monitor user accounts
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
          <FaUsers className="w-4 h-4" />
          <span className="font-medium">{rows} total users</span>
        </div>
      </div>

      {/* Action Bar */}
      <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] p-4">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
          {/* Left Actions */}
          <div className="flex flex-wrap gap-3">
            <Button
              text="Add New User"
              to="/users/add"
              iconPosition="left"
              icon={<RiApps2AddFill />}
              className="bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700 shadow-purple-500/25 hover:shadow-purple-500/40"
            />
            <Button
              text="Approve Users"
              to="/users/approve"
              iconPosition="left"
              icon={<FaUserCheck />}
              className="bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 shadow-green-500/25 hover:shadow-green-500/40"
            />
            <Button
              text="Deleted Users"
              to="/users/trash"
              iconPosition="left"
              icon={<MdDeleteForever />}
              className="bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 shadow-red-500/25 hover:shadow-red-500/40"
            />
          </div>

          {/* Right Filters */}
          <div className="flex flex-wrap gap-3">
            {/* Search */}
            <form onSubmit={searchData} className="relative">
              <div className="relative group">
                <input
                  type="text"
                  className="w-64 pl-11 pr-4 py-2.5 bg-gray-50 dark:bg-[#2a2a2a] border border-gray-200 dark:border-[#3a3a3a] rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent dark:text-white transition-all duration-200 group-hover:shadow-md"
                  placeholder="Search users..."
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                />
                <MdSearch className="absolute left-3.5 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              </div>
            </form>

            {/* Limit Selector */}
            <div className="relative">
              <select
                className="appearance-none bg-gray-50 dark:bg-[#2a2a2a] border border-gray-200 dark:border-[#3a3a3a] rounded-xl px-4 py-2.5 pr-10 text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent dark:text-white transition-all duration-200 hover:shadow-md cursor-pointer"
                onChange={(e) => setLimit(e.target.value)}
                value={limit}
              >
                <option value="10">Show 10</option>
                <option value="25">Show 25</option>
                <option value="50">Show 50</option>
                <option value="100">Show 100</option>
              </select>
              <MdKeyboardArrowDown className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            </div>
          </div>
        </div>
      </div>

      {/* Table Section */}
      <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] overflow-hidden relative">
        <div className="overflow-x-auto relative">
          {loading && (
            <div className="absolute inset-0 bg-white/50 dark:bg-[#1e1e1e]/50 flex items-center justify-center z-10">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            </div>
          )}

          <table className="w-full">
            <thead>
              <tr className="bg-gray-50 dark:bg-[#252525] border-b border-gray-200 dark:border-[#2a2a2a]">
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">#</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">User Details</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Email Address</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Role</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
              {users.length > 0 ? (
                users.map((user, index) => (
                  <tr
                    key={user.id}
                    className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group"
                  >
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="text-gray-900 dark:text-white">
                        {page * limit + index + 1}
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 bg-gradient-to-r from-green-500 to-green-600 rounded-full flex items-center justify-center text-white font-semibold text-sm">
                          {(user.fullname || user.email)
                            .charAt(0)
                            .toUpperCase()}
                        </div>
                        <div>
                          <div className="text-sm font-medium text-gray-900 dark:text-white">
                            {user.fullname || "No Name"}
                          </div>
                          <div className="text-sm text-gray-500 dark:text-gray-400">
                            ID: {user.id}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="text-sm text-gray-900 dark:text-white font-medium">
                        {user.email}
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      {getRoleBadge(user.role)}
                    </td>

                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <div className="flex items-center gap-1">
                          <ButtonAction
                            to={`/users/edit/${user.id}`}
                            icon={<MdEditSquare />}
                            className="bg-orange-500 hover:bg-orange-600"
                            title="Edit User"
                          />
                          <ButtonAction
                            to={`/users/${user.id}/details`}
                            icon={<BiSolidUserDetail />}
                            className="bg-blue-500 hover:bg-blue-600"
                            title="View Details"
                          />
                          <ButtonAction
                            to={`/users/${user.id}/points`}
                            icon={<RiCoinFill />}
                            className="bg-yellow-500 hover:bg-yellow-600"
                            title="Manage Points"
                          />
                          <ButtonAction
                            to={`/users/${user.id}/stats`}
                            icon={<BiStats />}
                            className="bg-purple-500 hover:bg-purple-600"
                            title="View Statistics"
                          />
                          <ButtonAction
                            onClick={() => handleReset(user.id)}
                            icon={<GrPowerReset />}
                            className="bg-green-500 hover:bg-green-600"
                            title="Reset Password"
                          />
                          <ButtonAction
                            onClick={() => deleteUser(user.id)}
                            icon={<MdDelete />}
                            className="bg-red-500 hover:bg-red-600"
                            title="Delete User"
                          />
                        </div>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="5" className="py-12 text-center">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-16 h-16 bg-gray-100 dark:bg-[#2a2a2a] rounded-full flex items-center justify-center">
                        <HiOutlineUsers className="w-8 h-8 text-gray-400" />
                      </div>
                      <div>
                        <h3 className="text-lg font-medium text-gray-900 dark:text-white">
                          No users found
                        </h3>
                        <p className="text-sm text-gray-500 dark:text-gray-400">
                          {query
                            ? `No users match "${query}"`
                            : "Get started by adding your first user"}
                        </p>
                      </div>
                      {!query && (
                        <Button
                          text="Add First User"
                          to="/users/add"
                          iconPosition="left"
                          icon={<RiApps2AddFill />}
                          className="bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium px-6 py-2.5 rounded-xl transition-all duration-200"
                        />
                      )}
                    </div>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Footer Section */}
      {users.length > 0 && (
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          {/* Stats */}
          <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
            <span className="font-medium">
              Showing {page * limit + 1} to {Math.min((page + 1) * limit, rows)}{" "}
              of {rows} users
            </span>
            <span className="text-gray-400">•</span>
            <span>
              Page {page + 1} of {pages}
            </span>
          </div>

          {/* Pagination */}
          <nav>
            <ReactPaginate
              previousLabel="← Previous"
              nextLabel="Next →"
              pageCount={Math.min(10, pages)}
              onPageChange={changePage}
              forcePage={page}
              containerClassName="flex items-center gap-1"
              pageLinkClassName="px-3 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-[#2a2a2a] border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150"
              previousLinkClassName="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-[#2a2a2a] border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150"
              nextLinkClassName="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-[#2a2a2a] border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150"
              activeLinkClassName="!bg-green-500 !text-white !border-green-500"
              disabledLinkClassName="opacity-50 cursor-not-allowed"
              breakLinkClassName="px-3 py-2 text-sm font-medium text-gray-500 dark:text-gray-400"
              pageClassName="hover:bg-gray-50 dark:hover:bg-[#252525]"
              previousClassName="hover:bg-gray-50 dark:hover:bg-[#252525]"
              nextClassName="hover:bg-gray-50 dark:hover:bg-[#252525]"
            />
          </nav>
        </div>
      )}

      {/* Error Message */}
      {message && (
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4">
          <p className="text-red-600 dark:text-red-400 text-sm font-medium">
            {message}
          </p>
        </div>
      )}
    </div>
  );
};

export default Layout;
