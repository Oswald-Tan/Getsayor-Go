import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import ButtonAction from "../../../components/ui/ButtonAction";
import {
  MdEditSquare,
  MdDelete,
  MdSearch,
  MdRemoveRedEye,
  MdKeyboardArrowDown,
} from "react-icons/md";
import ReactPaginate from "react-paginate";
import { HiOutlineClipboardList } from "react-icons/hi";
import ModalPesanan from "../../../components/ui/ModalPesanan";
import { formatShortDate } from "../../../utils/formateDate";
import Swal from "sweetalert2";

const Layout = () => {
  const [pesanan, setPesanan] = useState([]);
  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [message, setMessage] = useState("");
  const [pages, setPages] = useState(0);
  const [rows, setRows] = useState(0);
  const [keyword, setKeyword] = useState("");
  const [query, setQuery] = useState("");
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [typingTimeout, setTypingTimeout] = useState(null);
  const [loading, setLoading] = useState(false);

  const [selectedPesanan, setSelectedPesanan] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const openModal = (pesanan) => {
    setSelectedPesanan(pesanan);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setSelectedPesanan(null);
    setIsModalOpen(false);
  };

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
    getPesanan();
  }, [page, keyword, limit, selectedStatus]);

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

  const getPesanan = async () => {
    setLoading(true);
    try {
      const res = await axios.get(
        `${API_URL}/pesanan?search=${keyword}&page=${page}&limit=${limit}&status=${selectedStatus}`
      );

      if (Array.isArray(res.data?.data)) {
        setPesanan(res.data?.data);
      } else {
        setPesanan([]);
      }

      if (res.data && res.data.data) {
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
      console.error(
        "Error fetching data:",
        error.response ? error.response.data : error.message
      );
      setPesanan([]); // Set empty array in case of an error
    } finally {
      setLoading(false);
    }
  };

  const deletePesanan = async (id) => {
    Swal.fire({
      title: "Apakah Anda yakin?",
      text: "Pesanan ini akan dihapus secara permanen!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Ya, hapus!",
    }).then(async (result) => {
      if (result.isConfirmed) {
        await axios.delete(`${API_URL}/pesanan/${id}`);
        getPesanan();

        Swal.fire({
          icon: "success",
          title: "Deleted!",
          text: "Pesanan berhasil dihapus.",
        });
      }
    });
  };

  return (
    <>
      {isModalOpen && (
        <ModalPesanan pesanan={selectedPesanan} onClose={closeModal} />
      )}
      <div className="space-y-6">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <HiOutlineClipboardList className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Pesanan
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Manage and monitor your pesanan
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
            <HiOutlineClipboardList className="w-4 h-4" />
            <span className="font-medium">{rows} total pesanan</span>
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

              {/* Status filter */}
              <div className="flex items-center relative">
                <select
                  value={selectedStatus}
                  onChange={(e) => setSelectedStatus(e.target.value)}
                  className="appearance-none bg-gray-50 dark:bg-[#2a2a2a] border border-gray-200 dark:border-[#3a3a3a] rounded-xl px-4 py-2.5 pr-10 text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent dark:text-white transition-all duration-200 hover:shadow-md cursor-pointer"
                >
                  <option value="all">All Status</option>
                  <option value="pending">Pending</option>
                  <option value="confirmed">Confirmed</option>
                  <option value="processed">Processed</option>
                  <option value="out-for-delivery">Out for Delivery</option>
                  <option value="delivered">Delivered</option>
                  <option value="cancelled">Cancelled</option>
                </select>
                <span className="absolute right-3 text-gray-500">
                  <MdKeyboardArrowDown />
                </span>
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
            {/* Tabel responsif */}
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50 dark:bg-[#252525] border-b border-gray-200 dark:border-[#2a2a2a]">
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    #
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Order ID
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Dipesan
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Customer
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Pembayaran
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Total bayar
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Status
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
                {pesanan.length > 0 ? (
                  pesanan.map((pesanan, index) => (
                    <tr
                      key={index}
                      className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group"
                    >
                      <td className="py-4 px-6 whitespace-nowrap">
                        <div className="text-gray-900 dark:text-white">
                          {page * limit + index + 1}
                        </div>
                      </td>
                      <td className="py-4 px-6 whitespace-nowrap text-gray-900 dark:text-white">
                        {pesanan.OrderId || "-"}
                      </td>
                      <td className="py-4 px-6 whitespace-nowrap text-gray-900 dark:text-white">
                        {formatShortDate(pesanan.CreatedAt)}
                      </td>
                      <td className="py-4 px-6 whitespace-nowrap text-gray-900 dark:text-white">
                        {pesanan.User?.Details?.Fullname || "-"}
                      </td>
                      <td className="py-4 px-6 whitespace-nowrap">
                        {pesanan.MetodePembayaran === "Poin" ? (
                          <span className="px-2 py-1 text-xs text-white bg-yellow-500 rounded-lg">
                            {pesanan.MetodePembayaran}
                          </span>
                        ) : pesanan.MetodePembayaran === "COD" ? (
                          <span className="px-2 py-1 text-xs text-white bg-green-500 rounded-lg">
                            {pesanan.MetodePembayaran}
                          </span>
                        ) : (
                          pesanan.MetodePembayaran
                        )}
                      </td>

                      <td className="py-4 px-6 whitespace-nowrap">
                        {pesanan.HargaPoin ? (
                          <span className="px-2 py-1 text-xs text-white bg-yellow-500 rounded-lg">{`${pesanan.TotalBayar} Poin`}</span>
                        ) : pesanan.HargaRp ? (
                          <span className="px-2 py-1 text-xs text-white bg-green-500 rounded-lg">
                            Rp. {pesanan.TotalBayar.toLocaleString("id-ID")}
                          </span>
                        ) : (
                          "-"
                        )}
                      </td>

                      <td className="py-4 px-6 whitespace-nowrap">
                        {pesanan.Status === "pending" ? (
                          <span className="px-2 py-1 text-xs text-white bg-orange-600 rounded-lg">
                            Pending
                          </span>
                        ) : pesanan.Status === "confirmed" ? (
                          <span className="px-2 py-1 text-xs text-white bg-[#74B11A] rounded-lg">
                            Confirmed
                          </span>
                        ) : pesanan.Status === "processed" ? (
                          <span className="px-2 py-1 text-xs text-white bg-blue-600 rounded-lg">
                            Processed
                          </span>
                        ) : pesanan.Status === "out-for-delivery" ? (
                          <span className="px-2 py-1 text-xs text-white bg-purple-600 rounded-lg">
                            Out for Delivery
                          </span>
                        ) : pesanan.Status === "delivered" ? (
                          <span className="px-2 py-1 text-xs text-white bg-teal-600 rounded-lg">
                            Delivered
                          </span>
                        ) : (
                          <span className="px-2 py-1 text-xs text-white bg-red-600 rounded-lg">
                            Cancelled
                          </span>
                        )}
                      </td>
                      <td className="py-4 px-6 whitespace-nowrap">
                        <div className="flex items-center gap-1">
                          <ButtonAction
                            onClick={() => openModal(pesanan)}
                            icon={<MdRemoveRedEye />}
                            className={"bg-purple-500 hover:bg-purple-600"}
                          />

                          <ButtonAction
                            to={`/pesanan/edit/kurir/${pesanan.ID}`}
                            icon={<MdEditSquare />}
                            className={"bg-orange-500 hover:bg-orange-600"}
                          />
                          <ButtonAction
                            onClick={() => deletePesanan(pesanan.ID)}
                            icon={<MdDelete />}
                            className={"bg-red-500 hover:bg-red-600"}
                          />
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="11" className="py-12 text-center">
                      <div className="flex flex-col items-center gap-3">
                        <div className="w-16 h-16 bg-gray-100 dark:bg-[#2a2a2a] rounded-full flex items-center justify-center">
                          <HiOutlineClipboardList className="w-8 h-8 text-gray-400" />
                        </div>
                        <div>
                          <h3 className="text-lg font-medium text-gray-900 dark:text-white">
                            No pesanan found
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
        {pesanan.length > 0 && (
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            {/* Stats */}
            <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
              <span className="font-medium">
                Showing {page * limit + 1} to{" "}
                {Math.min((page + 1) * limit, rows)} of {rows} pesanan
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
