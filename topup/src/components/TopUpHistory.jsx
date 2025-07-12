import { useEffect, useState } from "react";
import axios from "axios";
import { format, isValid } from "date-fns";
import { id } from "date-fns/locale";
import { FaFileInvoice } from "react-icons/fa6";
import ReactPaginate from "react-paginate";
import { API_URL } from "../config.jsx";
import { useNavigate } from "react-router-dom";
import Button from "./ui/Button.jsx";
import { MdKeyboardArrowDown } from "react-icons/md";

// Komponen untuk format tanggal
const FormatDate = ({ dateString }) => {
  try {
    if (!dateString) return <span className="text-gray-400">-</span>;

    const date = new Date(dateString);
    if (!isValid(date)) throw new Error("Invalid date");

    return <span>{format(date, "dd MMM yyyy HH:mm", { locale: id })}</span>;
  } catch (error) {
    console.error("Error formatting date:", dateString, error);
    return <span className="text-gray-400">-</span>;
  }
};

const TopUpHistory = () => {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [pages, setPages] = useState(0);
  const [rows, setRows] = useState(0);
  const [message, setMessage] = useState("");

  const changePage = ({ selected }) => {
    setPage(selected);
    setMessage("");
  };

  const fetchTransactions = async () => {
    try {
      setLoading(true);
      const res = await axios.get(
        `${API_URL}/topup-from-web?page=${page}&limit=${limit}&status=${selectedStatus}`
      );

      const responseData = res.data.data || [];

      setTransactions(res.data.data || []);
      setPages(res.data.totalPage);
      setRows(res.data.totalRows);
      setPage(res.data.page);

      if (responseData.length === 0 && page > 0) {
        setPage(0);
      }
    } catch (err) {
      console.error("Fetch error:", err.response?.data || err.message);
      setMessage("Gagal memuat riwayat top-up");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, [page, limit, selectedStatus]);

  const getStatusColor = (status) => {
    switch (status) {
      case "approved":
        return "bg-green-100 text-green-800";
      case "pending":
        return "bg-yellow-100 text-yellow-800";
      case "cancelled":
        return "bg-red-100 text-red-800";
        case "rejected":
          return "bg-gray-100 text-gray-800";  
      default:
        return "bg-gray-100 text-gray-800";
    }
  };

  return (
    <div className="max-w-4xl mx-auto relative min-h-screen">
      {/* Loading Screen Overlay */}
      {loading && (
        <div className="fixed inset-0 bg-white bg-opacity-80 z-50 flex items-center justify-center">
          <div className="text-center">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-600 mb-4"></div>
            <p className="text-gray-700 font-medium">Memuat riwayat top-up...</p>
          </div>
        </div>
      )}

      <h1 className="text-2xl font-bold text-gray-800 mb-6 text-center pt-6">
        Riwayat Top Up
      </h1>

      <div className="flex items-center justify-between">
        {/* Status filter */}
        <div className="flex items-center relative">
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value)}
            className="px-4 py-2 border dark:text-white border-gray-300 dark:border-[#3f3f3f] rounded-md text-xs appearance-none pr-7 focus:outline-none dark:bg-[#282828]"
          >
            <option value="all">All Status</option>
            <option value="pending">Waiting</option>
            <option value="approved">Succeed</option>
            <option value="rejected">Rejected</option>
            <option value="cancelled">Cancelled</option>
          </select>
          <span className="absolute right-3 text-gray-500">
            <MdKeyboardArrowDown />
          </span>
        </div>

        {/* Limit filter */}
        <div className="flex items-center overflow-x-auto">
          <div className="flex items-center relative">
            <select
              id="limit"
              name="limit"
              className="px-4 py-2 border dark:text-white border-gray-300 dark:border-[#3f3f3f] rounded-md text-xs appearance-none pr-7 focus:outline-none dark:bg-[#282828]"
              onChange={(e) => setLimit(e.target.value)}
            >
              <option value="10">10</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
            <span className="absolute right-3 text-gray-500">
              <MdKeyboardArrowDown />
            </span>
          </div>
        </div>
      </div>

      <div className="overflow-x-auto bg-white rounded-xl p-4 mt-5">
        <table className="table-auto w-full text-left">
          <thead>
            <tr className="text-sm dark:text-white">
              <th className="px-4 py-2 border-b whitespace-nowrap">No</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Tanggal</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Poin</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Nominal</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Status</th>
              <th className="px-4 py-2 border-b whitespace-nowrap">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {transactions.length > 0 ? (
              Array.isArray(transactions) && transactions.map((transaction, index) => (
                <tr key={index} className="text-sm">
                  <td className="px-4 py-2 border-b whitespace-nowrap">
                  {index + 1}
                  </td>
                  <td className="px-4 py-2 border-b whitespace-nowrap">
                    <FormatDate dateString={transaction.created_at} />
                  </td>
                  <td className="px-4 py-2 border-b whitespace-nowrap">
                    {transaction.points?.toLocaleString() || 0} Poin
                  </td>
                  <td className="px-4 py-2 border-b whitespace-nowrap">
                    Rp {transaction.price?.toLocaleString() || 0}
                  </td>
                  <td className="px-4 py-2 border-b whitespace-nowrap">
                    <span
                      className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(
                        transaction.status
                      )}`}
                    >
                      {transaction.status === "approved" && "Succeed"}
                      {transaction.status === "pending" && "Waiting"}
                      {transaction.status === "rejected" && "Rejected"}
                      {transaction.status === "cancelled" && "Cancelled"}
                    </span>
                  </td>
                  <td className="px-4 py-2 border-b whitespace-nowrap">
                    <Button
                      text="Invoice"
                      onClick={() =>
                        navigate("/invoice", {
                          state: {
                            transactionId: transaction.id,
                            points: transaction.points,
                            price: transaction.price,
                            bankName: transaction.bankName || "BCA",
                            date: transaction.created_at,
                          },
                        })
                      }
                      icon={<FaFileInvoice size={16} />}
                      iconPosition="left"
                      className="bg-blue-600 hover:bg-blue-700 text-white font-medium text-xs px-3 py-1"
                    />
                  </td>
                </tr>
              ))) : ( <tr>
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

      <p className="mt-5 text-sm text-inverted-color pr-2 dark:text-white">
        Total Rows: {rows} Page: {rows ? page + 1 : 0} of {pages}
      </p>
      <div>
        <span className="text-red-500">{message}</span>
      </div>

      {!loading && transactions.length > 0 ? (
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
    </div>
  );
};

export default TopUpHistory;