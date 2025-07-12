import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../config";
import ButtonAction from "./ui/ButtonAction";
import {
  MdEditSquare,
  MdDelete,
  MdSearch,
  MdRemoveRedEye,
  MdKeyboardArrowDown,
} from "react-icons/md";
import ReactPaginate from "react-paginate";
import ModalPesanan from "./ui/ModalPesanan";
import { formatShortDate } from "../utils/formateDate";
import Swal from "sweetalert2";

const PesananList = () => {
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
    try {
      const res = await axios.get(
        `${API_URL}/pesanan?search=${keyword}&page=${page}&limit=${limit}&status=${selectedStatus}`
      );

      if (Array.isArray(res.data?.data)) {
        setPesanan(res.data?.data);
        console.log(res.data?.data);
      } else {
        setPesanan([]); // Set empty array if the response is not an array
      }

      // Assuming 'totalPage' and 'totalRows' are properties in the response data
      setPages(res.data.totalPage);
      setRows(res.data.totalRows);
      setPage(res.data.page);
    } catch (error) {
      console.error(
        "Error fetching data:",
        error.response ? error.response.data : error.message
      );
      setPesanan([]); // Set empty array in case of an error
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
      <div>
        <h2 className="text-2xl font-semibold mb-4 dark:text-white">Pesanan</h2>

        <div className="flex gap-2 mt-5 overflow-x-auto">
          {/* Search filter */}
          <form onSubmit={searchData}>
            <div className="flex items-center relative w-[220px]">
              <input
                type="text"
                className="pr-10 pl-4 py-2 border dark:text-white border-gray-300 dark:border-[#3f3f3f] rounded-md w-full text-xs focus:outline-none dark:bg-[#282828]"
                placeholder="Search..."
                value={query}
                onChange={(e) => setQuery(e.target.value)}
              />
              <MdSearch
                size={20}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400"
              />
            </div>
          </form>

          {/* Limit filter */}
          <form>
            <div className="flex items-center relative">
              <select
                id="limit"
                name="limit"
                className="px-4 py-2 border dark:text-white border-gray-300 dark:border-[#3f3f3f] rounded-md text-xs appearance-none pr-7 focus:outline-none dark:bg-[#282828]" 
                onChange={(e) => {
                  setLimit(e.target.value);
                }}
              >
                <option value="10">10</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
              {/* Menambahkan ikon dropdown di luar select */}
              <span className="absolute right-3 text-gray-500">
                <MdKeyboardArrowDown />
              </span>
            </div>
          </form>

          {/* Status filter */}
          <div className="flex items-center relative">
            <select
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              className="px-4 py-2 border dark:text-white border-gray-300 dark:border-[#3f3f3f] rounded-md text-xs appearance-none pr-7 focus:outline-none dark:bg-[#282828]" 
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
        <div className="overflow-x-auto bg-white dark:bg-[#282828] rounded-xl p-4 mt-5">
          {/* Tabel responsif */}
          <table className="table-auto w-full text-left text-black-100">
            <thead>
              <tr className="text-sm dark:text-white">
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">No</th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Order ID
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Created at
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Customer
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Pembayaran
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Total bayar
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Status</th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody>
              {pesanan.length > 0 ? (
                pesanan.map((pesanan, index) => (
                  <tr key={index} className="text-sm dark:text-white">
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {index + 1}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {pesanan.orderId || "-"}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {formatShortDate(pesanan.created_at)}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {pesanan.user?.userDetails?.fullname || "-"}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {pesanan.metodePembayaran === "Poin" ? (
                        <span className="px-2 py-1 text-xs text-white bg-yellow-500 rounded-lg">
                          {pesanan.metodePembayaran}
                        </span>
                      ) : pesanan.metodePembayaran === "COD" ? (
                        <span className="px-2 py-1 text-xs text-white bg-green-500 rounded-lg">
                          {pesanan.metodePembayaran}
                        </span>
                      ) : (
                        pesanan.metodePembayaran
                      )}
                    </td>

                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {pesanan.hargaPoin ? (
                        <span className="px-2 py-1 text-xs text-white bg-yellow-500 rounded-lg">{`${pesanan.totalBayar} Poin`}</span>
                      ) : pesanan.hargaRp ? (
                        <span className="px-2 py-1 text-xs text-white bg-green-500 rounded-lg">
                          Rp. {pesanan.totalBayar.toLocaleString("id-ID")}
                        </span>
                      ) : (
                        "-"
                      )}
                    </td>

                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {pesanan.status === "pending" ? (
                        <span className="px-2 py-1 text-xs text-white bg-orange-600 rounded-lg">
                          Pending
                        </span>
                      ) : pesanan.status === "confirmed" ? (
                        <span className="px-2 py-1 text-xs text-white bg-[#74B11A] rounded-lg">
                          Confirmed
                        </span>
                      ) : pesanan.status === "processed" ? (
                        <span className="px-2 py-1 text-xs text-white bg-blue-600 rounded-lg">
                          Processed
                        </span>
                      ) : pesanan.status === "out-for-delivery" ? (
                        <span className="px-2 py-1 text-xs text-white bg-purple-600 rounded-lg">
                          Out for Delivery
                        </span>
                      ) : pesanan.status === "delivered" ? (
                        <span className="px-2 py-1 text-xs text-white bg-teal-600 rounded-lg">
                          Delivered
                        </span>
                      ) : (
                        <span className="px-2 py-1 text-xs text-white bg-red-600 rounded-lg">
                          Cancelled
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      <div className="flex gap-x-2">
                        <ButtonAction
                          onClick={() => openModal(pesanan)}
                          icon={<MdRemoveRedEye />}
                          className={"bg-purple-600 hover:bg-purple-700"}
                        />

                        <ButtonAction
                          to={`/pesanan/edit/${pesanan.id}`}
                          icon={<MdEditSquare />}
                          className={"bg-orange-600 hover:bg-orange-700"}
                        />
                        <ButtonAction
                          onClick={() => deletePesanan(pesanan.id)}
                          icon={<MdDelete />}
                          className={"bg-red-600 hover:bg-red-700"}
                        />
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td
                    colSpan="9"
                    className="px-4 pt-4 text-center text-sm text-gray-500"
                  >
                    Belum ada data
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      <p className="mt-5 text-sm text-inverted-color pr-2 dark:text-white">
        Total Rows: {rows} Page: {rows ? page + 1 : 0} of {pages}
      </p>
      <div>
        <span className="text-red-500">{message}</span>
      </div>

      {pesanan.length > 0 ? (
        <nav key={rows}>
          <ReactPaginate
            previousLabel={"<"}
            nextLabel={">"}
            pageCount={Math.min(10, pages)}
            onPageChange={changePage}
            containerClassName="flex mt-2 list-none gap-1"
            pageLinkClassName="px-3 py-1 bg-blue-500 text-white rounded transition-all duration-300 cursor-pointer hover:bg-blue-400"
            previousLinkClassName="px-3 py-1 bg-blue-500 text-white rounded transition-all duration-300 cursor-pointer hover:bg-blue-400"
            nextLinkClassName="px-3 py-1 bg-blue-500 text-white rounded transition-all duration-300 cursor-pointer hover:bg-blue-400"
            activeLinkClassName="bg-purple-700 text-white cursor-default"
            disabledLinkClassName="opacity-50 cursor-not-allowed"
          />
        </nav>
      ) : null}
    </>
  );
};

export default PesananList;
