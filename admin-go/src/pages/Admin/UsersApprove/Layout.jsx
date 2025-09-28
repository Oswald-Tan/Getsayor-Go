import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import Button from "../../../components/ui/Button";
import ButtonAction from "../../../components/ui/ButtonAction";
import { MdSearch, MdKeyboardArrowDown } from "react-icons/md";
import { BiSolidSelectMultiple } from "react-icons/bi";
import { FaCircleCheck } from "react-icons/fa6";
import { FaUserCheck } from "react-icons/fa6";
import ReactPaginate from "react-paginate";
import { HiOutlineUsers } from "react-icons/hi2";

const Layout = () => {
  const [users, setUsers] = useState([]);
  const [selectedUsers, setSelectedUsers] = useState([]);
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

  const handleSelectUser = (userId) => {
    setSelectedUsers((prev) =>
      prev.includes(userId)
        ? prev.filter((id) => id !== userId)
        : [...prev, userId]
    );
  };

  const handleSelectAllUsers = () => {
    if (selectedUsers.length === users.length) {
      setSelectedUsers([]);
    } else {
      setSelectedUsers(users.map((user) => user.id));
    }
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
    // Menangani pencarian otomatis
    if (typingTimeout) {
      clearTimeout(typingTimeout); // Menghapus timeout yang ada
    }
    const timeout = setTimeout(() => {
      setKeyword(query); // Mengatur keyword untuk pencarian
    }, 300); // Delay 300ms sebelum melakukan pencarian

    setTypingTimeout(timeout); // Menyimpan timeout
    return () => clearTimeout(timeout); // Membersihkan timeout saat komponen di-unmount
  }, [query]);

  const getUsers = async () => {
    setLoading(true);
    try {
      const res = await axios.get(
        `${API_URL}/users/approve?search=${keyword}&page=${page}&limit=${limit}`
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
      console.error("Error fetching data", error.response);
    } finally {
      setLoading(false);
    }
  };

  const handleApproveUser = async (userId) => {
    const confirmApprove = await Swal.fire({
      title: "Apakah Anda yakin?",
      text: "User ini akan disetujui untuk login!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, setujui!",
      cancelButtonText: "Batal",
      customClass: {
        popup: "rounded-xl",
        confirmButton: "rounded-lg",
        cancelButton: "rounded-lg",
      },
    });

    if (confirmApprove.isConfirmed) {
      try {
        const response = await axios.put(`${API_URL}/users/approve`, {
          userId,
        });

        if (response.status === 200) {
          Swal.fire({
            title: "Berhasil!",
            text: "User telah disetujui.",
            icon: "success",
          });
          getUsers();
        }
      } catch (error) {
        console.error("Gagal menyetujui user", error.response);
      }
    }
  };

  const handleApproveSelectedUsers = async () => {
    if (selectedUsers.length === 0) {
      Swal.fire({
        title: "Peringatan!",
        text: "Pilih pengguna terlebih dahulu!",
        icon: "warning",
      });
      return;
    }

    const confirmApprove = await Swal.fire({
      title: "Apakah Anda yakin?",
      text: "User yang dipilih akan disetujui untuk login!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Ya, setujui!",
      cancelButtonText: "Batal",
    });

    if (confirmApprove.isConfirmed) {
      try {
        const response = await axios.put(`${API_URL}/users/approve-users`, {
          userIds: selectedUsers,
        });

        if (response.status === 200) {
          Swal.fire({
            title: "Berhasil!",
            text: "User telah disetujui.",
            icon: "success",
          });
          setSelectedUsers([]);
          getUsers();
        }
      } catch (error) {
        console.error("Gagal menyetujui user", error.response);
      }
    }
  };

  return (
    <>
      <div className="space-y-6">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <HiOutlineUsers className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Users Approve
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Manage and monitor user approve
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
            <HiOutlineUsers className="w-4 h-4" />
            <span className="font-medium">{rows} total users</span>
          </div>
        </div>

        {/* Action Bar */}
        <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] p-4">
          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
            {/* Left Actions */}
            <div className="flex flex-wrap gap-3">
              <Button
                text="Sellect All"
                iconPosition="left"
                onClick={handleSelectAllUsers}
                icon={<BiSolidSelectMultiple />}
                className="bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700 shadow-purple-500/25 hover:shadow-purple-500/40"
              />
              <Button
                text="Approve All User"
                iconPosition="left"
                onClick={handleApproveSelectedUsers}
                icon={<FaUserCheck />}
                className="bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 shadow-green-500/25 hover:shadow-green-500/40"
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
                    <input
                      type="checkbox"
                      onChange={handleSelectAllUsers}
                      checked={selectedUsers.length === users.length}
                    />
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Fullname
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Email
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Role
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
                {users.length > 0 ? (
                  users.map((user) => (
                    <tr
                      key={user.id}
                      className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group"
                    >
                      <td className="py-4 px-6 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                        <input
                          type="checkbox"
                          checked={selectedUsers.includes(user.id)}
                          onChange={() => handleSelectUser(user.id)}
                        />
                      </td>
                      <td className="py-4 px-6 text-gray-900 dark:text-white border-b dark:border-[#3f3f3f] whitespace-nowrap">
                        {user.fullname}
                      </td>
                      <td className="py-4 px-6 text-gray-900 dark:text-white border-b dark:border-[#3f3f3f] whitespace-nowrap">
                        {user.email}
                      </td>
                      <td className="py-4 px-6 text-gray-900 dark:text-white border-b dark:border-[#3f3f3f] whitespace-nowrap">
                        {user.role === "admin" ? (
                          <span className="px-2 py-1 text-xs text-orange-600 border border-orange-600 rounded-lg">
                            Admin
                          </span>
                        ) : user.role === "user" ? (
                          <span className="px-2 py-1 text-xs text-green-600 border border-green-600 rounded-lg">
                            User
                          </span>
                        ) : (
                          <span className="px-2 py-1 text-xs text-blue-600 border border-blue-600 rounded-lg">
                            Delivery
                          </span>
                        )}
                      </td>

                      <td className="px-6 py-4 border-b dark:border-[#3f3f3f]">
                        <div className="flex gap-x-2">
                          <ButtonAction
                            icon={<FaCircleCheck />}
                            className={"bg-green-500 hover:bg-green-600"}
                            onClick={() => handleApproveUser(user.id)}
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
                            No users found
                          </h3>
                          <p className="text-sm text-gray-500 dark:text-gray-400">
                            {query
                              ? `No users match "${query}"`
                              : "Get started by adding your first user"}
                          </p>
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
    </>
  );
};

export default Layout;
