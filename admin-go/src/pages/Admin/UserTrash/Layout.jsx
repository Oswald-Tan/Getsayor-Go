import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import ButtonAction from "../../../components/ui/ButtonAction";
import {
  MdRestore,
  MdDeleteForever,
  MdKeyboardArrowDown,
  MdSearch,
} from "react-icons/md";
import { HiOutlineUsers } from "react-icons/hi2";
import ReactPaginate from "react-paginate";
import { FaUsers } from "react-icons/fa6";

const Layout = () => {
  const [deletedUsers, setDeletedUsers] = useState([]);
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
    getDeletedUsers();
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

  const getDeletedUsers = async () => {
    setLoading(true);
    try {
      const res = await axios.get(
        `${API_URL}/users/deleted?search=${keyword}&page=${page}&limit=${limit}`
      );

      if (res.data && res.data.data) {
        setDeletedUsers(res.data.data || []);
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

  const restoreUser = async (userId) => {
    Swal.fire({
      title: "Restore User?",
      text: "This user will be restored to active status",
      icon: "question",
      showCancelButton: true,
      confirmButtonColor: "#10b981",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Yes, restore!",
      customClass: {
        popup: "rounded-xl",
        confirmButton: "rounded-lg",
        cancelButton: "rounded-lg",
      },
    }).then(async (result) => {
      if (result.isConfirmed) {
        try {
          await axios.put(`${API_URL}/users/restore/${userId}`);
          Swal.fire("Restored!", "User has been restored.", "success");
          getDeletedUsers();
        } catch (error) {
          Swal.fire(
            "Error!",
            error.response?.data?.error || "Restore failed",
            "error"
          );
        }
      }
    });
  };

  const permanentDelete = async (userId) => {
    Swal.fire({
      title: "Permanent Delete?",
      text: "This cannot be undone! User will be permanently deleted",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc2626",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Yes, delete permanently!",
      customClass: {
        popup: "rounded-xl",
        confirmButton: "rounded-lg",
        cancelButton: "rounded-lg",
      },
    }).then(async (result) => {
      if (result.isConfirmed) {
        try {
          await axios.delete(`${API_URL}/users/permanent/${userId}`);
          Swal.fire("Deleted!", "User permanently deleted.", "success");
          getDeletedUsers();
        } catch (error) {
          Swal.fire(
            "Error!",
            error.response?.data?.error || "Delete failed",
            "error"
          );
        }
      }
    });
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
              Deleted Users
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Restore or permanently delete users
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
          <FaUsers className="w-4 h-4" />
          <span className="font-medium">{rows} total deleted users</span>
        </div>
      </div>

      {/* Action Bar */}
      <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] p-4">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
          {/* Right Filters */}

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

      {/* Table */}
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
                  <div className="flex items-center">User</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Deleted At</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
              {deletedUsers.length > 0 ? (
                deletedUsers.map((user, index) => (
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
                        <div className="w-10 h-10 bg-gradient-to-r from-gray-400 to-gray-500 rounded-full flex items-center justify-center text-white font-semibold">
                          {user.email.charAt(0).toUpperCase()}
                        </div>
                        <div>
                          <div className="font-medium text-gray-900 dark:text-white">
                            {user.email}
                          </div>
                          <div className="text-sm text-gray-500">
                            ID: {user.id}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6 text-sm text-gray-500">
                      {user.deleted_at
                        ? new Date(user.deleted_at).toLocaleString()
                        : "N/A"}
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="flex items-center gap-1">
                        <ButtonAction
                          onClick={() => restoreUser(user.id)}
                          icon={<MdRestore />}
                          className="bg-green-500 hover:bg-green-600"
                          title="Restore User"
                        />
                        <ButtonAction
                          onClick={() => permanentDelete(user.id)}
                          icon={<MdDeleteForever />}
                          className="bg-red-500 hover:bg-red-600"
                          title="Permanent Delete"
                        />
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
                          No user deleted found
                        </h3>
                      </div>
                    </div>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Footer Section */}
      {deletedUsers.length > 0 && (
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
