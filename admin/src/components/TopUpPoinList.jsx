import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../config";
import ButtonAction from "./ui/ButtonAction";
import Swal from "sweetalert2";
import { MdDelete, MdKeyboardArrowDown } from "react-icons/md";
import { formatDate, formatRupiah } from "../utils/formateDate";
import ReactPaginate from "react-paginate";
import { MdSearch } from "react-icons/md";

const TopUpPoinList = () => {
  const [topUp, setTopUp] = useState([]);
  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [message, setMessage] = useState("");
  const [pages, setPages] = useState(0);
  const [rows, setRows] = useState(0);
  const [keyword, setKeyword] = useState("");
  const [query, setQuery] = useState("");
  const [typingTimeout, setTypingTimeout] = useState(null);

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

  const getTopUpPoin = async () => {
    try {
      const res = await axios.get(
        `${API_URL}/topup?search=${keyword}&page=${page}&limit=${limit}`
      );
      setTopUp(res.data.data || []); // Pastikan data array atau fallback ke array kosong
      setPages(res.data.totalPage || 0);
      setRows(res.data.totalRows || 0);
      setPage(res.data.page || 0);

      if (res.data.data.length === 0 && page > 0) {
        setPage(0);
      }
    } catch (error) {
      console.error("Error fetching data", error);
    }
  };

  const deleteTopUpPoin = async (id) => {
    Swal.fire({
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Yes, delete it!",
    }).then(async (result) => {
      if (result.isConfirmed) {
        await axios.delete(`${API_URL}/topup/${id}`);
        getTopUpPoin();

        Swal.fire({
          icon: "success",
          title: "Deleted!",
          text: "Top Up deleted successfully.",
        });
      }
    });
  };

  return (
    <>
      <div>
        <h2 className="text-2xl font-semibold dark:text-white">Top Up</h2>

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
        </div>
        <div className="overflow-x-auto bg-white dark:bg-[#282828] rounded-xl p-4 mt-5">
          {/* Tabel responsif */}
          <table className="table-auto w-full text-left text-black-100">
            <thead>
              <tr className="text-sm dark:text-white">
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  No
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Fullname
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Email
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Poin
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Price
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Date
                </th>
                {/* <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Bank</th> */}
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Status
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody>
              {topUp.length > 0 ? (
                Array.isArray(topUp) &&
                topUp.map((topup, index) => (
                  <tr key={index} className="text-sm dark:text-white">
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {index + 1}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {topup.User.userDetails?.fullname}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {topup.User.email}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {topup.points}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                     {formatRupiah(topup.price)}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {formatDate(topup.created_at)}
                    </td>
                    {/* <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {topup.bankName}
                    </td> */}
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      <span className="px-2 py-1 text-xs text-green-800 bg-green-100 rounded-lg">
                        {topup.status.charAt(0).toUpperCase() +
                          topup.status.slice(1)}
                      </span>
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      <div className="flex gap-x-2">
                        {topup.status === "approved" ? (
                          <span className="text-gray-500">-</span>
                        ) : (
                          <>
                            <ButtonAction
                              onClick={() => deleteTopUpPoin(topup.id)}
                              icon={<MdDelete />}
                              className={"bg-red-600 hover:bg-red-700"}
                            />
                          </>
                        )}
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

      <p className="mt-5 text-sm dark:text-white text-inverted-color pr-2">
        Total Rows: {rows} Page: {rows ? page + 1 : 0} of {pages}
      </p>
      <div>
        <span className="text-red-500">{message}</span>
      </div>

      {topUp.length > 0 ? (
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

export default TopUpPoinList;
