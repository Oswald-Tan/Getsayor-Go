import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import ButtonAction from "../../../components/ui/ButtonAction";
import Swal from "sweetalert2";
import { MdDelete, MdKeyboardArrowDown, MdSearch } from "react-icons/md";
import { formatDate, formatRupiah } from "../../../utils/formateDate";
import ReactPaginate from "react-paginate";
import { LuHandCoins } from "react-icons/lu";
import { RiExchangeDollarFill } from "react-icons/ri";
import Poin from "../../../assets/poin_cs.png";

const Layout = () => {
  const [topUp, setTopUp] = useState([]);
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
    getTopUpPoin();
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

  const getTopUpPoin = async () => {
    setLoading(true);
    try {
      const res = await axios.get(
        `${API_URL}/topup-web?search=${keyword}&page=${page}&limit=${limit}`
      );

      if (res.data && res.data.data) {
        setTopUp(res.data.data || []);
        setPages(res.data.totalPage || 0);
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

  const deleteTopUpPoin = async (id) => {
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
        await axios.delete(`${API_URL}/topup-web/${id}`);
        getTopUpPoin();

        Swal.fire({
          icon: "success",
          title: "Deleted!",
          text: "Top Up deleted successfully.",
          customClass: {
            popup: "rounded-xl",
            confirmButton: "rounded-lg",
          },
        });
      }
    });
  };

  const getStatusBadge = (status) => {
    const statusConfig = {
      approved: {
        color: "bg-green-100 text-green-800 border-green-300",
        darkColor:
          "dark:bg-green-900/30 dark:text-green-300 dark:border-green-700",
      },
      pending: {
        color: "bg-yellow-100 text-yellow-800 border-yellow-300",
        darkColor:
          "dark:bg-yellow-900/30 dark:text-yellow-300 dark:border-yellow-700",
      },
      rejected: {
        color: "bg-red-100 text-red-800 border-red-300",
        darkColor: "dark:bg-red-900/30 dark:text-red-300 dark:border-red-700",
      },
    };

    const config = statusConfig[status.toLowerCase()] || statusConfig.pending;

    return (
      <span
        className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold border ${config.color} ${config.darkColor} transition-all duration-200`}
      >
        {status.charAt(0).toUpperCase() + status.slice(1)}
      </span>
    );
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
            <LuHandCoins className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Top Up Management
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Manage and monitor point top-ups
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
          <LuHandCoins className="w-4 h-4" />
          <span className="font-medium">{rows} total transactions</span>
        </div>
      </div>

      {/* Action Bar */}
      <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] p-4">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
          {/* Right Filters */}
          <div className="flex flex-wrap gap-3">
            {/* Search */}
            <form onSubmit={searchData} className="relative">
              <div className="relative group">
                <input
                  type="text"
                  className="w-64 pl-11 pr-4 py-2.5 bg-gray-50 dark:bg-[#2a2a2a] border border-gray-200 dark:border-[#3a3a3a] rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent dark:text-white transition-all duration-200 group-hover:shadow-md"
                  placeholder="Search transactions..."
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
        {loading && (
          <div className="absolute inset-0 bg-white/50 dark:bg-[#1e1e1e]/50 flex items-center justify-center z-10">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-500"></div>
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-gray-50 dark:bg-[#252525] border-b border-gray-200 dark:border-[#2a2a2a]">
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">#</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Fullname</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Points</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Price</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Date</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Status</div>
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  <div className="flex items-center">Actions</div>
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
              {topUp.length > 0 ? (
                topUp.map((topup, index) => (
                  <tr
                    key={topup.id}
                    className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group"
                  >
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="text-gray-900 dark:text-white">
                        {page * limit + index + 1}
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div>
                        <div className="text-sm font-medium text-gray-900 dark:text-white">
                          {topup.User?.Details?.Fullname || "Unknown User"}
                        </div>
                        <div className="text-sm text-gray-500 dark:text-gray-400">
                          {topup.User?.Email || "No email"}
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="flex items-center gap-1">
                        <img src={Poin} alt="Poin" className="w-4 h-4" />
                        <span className="text-sm font-medium text-gray-900 dark:text-white">
                          {topup.Points}
                        </span>
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900 dark:text-white">
                        {formatRupiah(topup.Price)}
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="text-sm text-gray-500 dark:text-gray-400">
                        {formatDate(topup.CreatedAt)}
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      {getStatusBadge(topup.Status)}
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <div className="flex items-center gap-1">
                          {topup.Status === "approved" ? (
                            <span className="text-xs text-gray-500 italic">
                              No actions
                            </span>
                          ) : (
                            <>
                              <ButtonAction
                                onClick={() => deleteTopUpPoin(topup.id)}
                                icon={<MdDelete />}
                                className="bg-red-500 hover:bg-red-600"
                                title="Delete Transaction"
                              />
                            </>
                          )}
                        </div>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="8" className="py-12 text-center">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-16 h-16 bg-gray-100 dark:bg-[#2a2a2a] rounded-full flex items-center justify-center">
                        <RiExchangeDollarFill className="w-8 h-8 text-gray-400" />
                      </div>
                      <div>
                        <h3 className="text-lg font-medium text-gray-900 dark:text-white">
                          No top-up transactions
                        </h3>
                        <p className="text-sm text-gray-500 dark:text-gray-400">
                          {query
                            ? `No transactions match "${query}"`
                            : "All transactions will appear here"}
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
      {topUp.length > 0 && (
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          {/* Stats */}
          <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
            <span className="font-medium">
              Showing {page * limit + 1} to {Math.min((page + 1) * limit, rows)}{" "}
              of {rows} transactions
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
