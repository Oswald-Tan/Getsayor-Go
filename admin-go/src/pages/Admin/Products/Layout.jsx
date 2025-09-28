import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL, API_URL_STATIC } from "../../../config";
import Button from "../../../components/ui/Button";
import ButtonAction from "../../../components/ui/ButtonAction";
import { RiApps2AddFill } from "react-icons/ri";
import {
  MdEditSquare,
  MdDelete,
  MdRemoveRedEye,
  MdSearch,
  MdKeyboardArrowDown,
} from "react-icons/md";
import Swal from "sweetalert2";
import ModalProduct from "../../../components/ui/ModalProduct";
import ReactPaginate from "react-paginate";
import { AiOutlineProduct } from "react-icons/ai";

const Layout = () => {
  const [products, setProducts] = useState([]);
  const [selectedProduct, setselectedProduct] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [message, setMessage] = useState("");
  const [pages, setPages] = useState(0);
  const [rows, setRows] = useState(0);
  const [keyword, setKeyword] = useState("");
  const [query, setQuery] = useState("");
  const [typingTimeout, setTypingTimeout] = useState(null);
  const [loading, setLoading] = useState(false);

  const openModal = (product) => {
    setselectedProduct(product);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setselectedProduct(null);
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
    getProduct();
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

  const getProduct = async () => {
  setLoading(true);
  try {
    const res = await axios.get(`${API_URL}/products`, {
      params: {
        search: keyword,
        page: page,
        limit: limit,
      },
    });

    if (res.data && res.data.data) {
        setProducts(res.data.data || 0);
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
    console.error("Error fetching data", error);
  } finally {
    setLoading(false);
  }
};

  const deleteProduct = async (id) => {
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
        await axios.delete(`${API_URL}/products/${id}`);
        getProduct();

        Swal.fire({
          icon: "success",
          title: "Deleted!",
          text: "Product deleted successfully.",
        });
      }
    });
  };

  return (
    <>
      {isModalOpen && (
        <ModalProduct product={selectedProduct} onClose={closeModal} />
      )}

      <div className="space-y-6">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <AiOutlineProduct className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Products
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Manage and monitor your products
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
            <AiOutlineProduct className="w-4 h-4" />
            <span className="font-medium">{rows} total produk</span>
          </div>
        </div>

        {/* Action Bar */}
        <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] p-4">
          <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
            {/* Left Actions */}
            <div className="flex flex-wrap gap-3">
              <Button
                text="Add New"
                to="/products/add"
                iconPosition="left"
                icon={<RiApps2AddFill />}
                className="bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700 shadow-purple-500/25 hover:shadow-purple-500/40"
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
                    placeholder="Search products..."
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
        <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] overflow-hidden">
          {loading && (
            <div className="absolute inset-0 bg-white/50 dark:bg-[#1e1e1e]/50 flex items-center justify-center z-10">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            </div>
          )}

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50 dark:bg-[#252525] border-b border-gray-200 dark:border-[#2a2a2a]">
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                    #
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                    Nama Produk
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                    Deskripsi
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                    Stok
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                    Harga
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                    Berat
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                    Image
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
                {products.length > 0 ? (
                  products.map((product, index) => {
                    // Get the first variant for display
                    const firstVariant = product.productItems?.[0] || {};

                    return (
                      <tr
                        key={index}
                        className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group"
                      >
                        <td className="py-4 px-6 whitespace-nowrap">
                          <div className="text-gray-900 dark:text-white">
                            {page * limit + index + 1}
                          </div>
                        </td>

                        <td className="py-4 px-6 whitespace-nowrap">
                          <div>
                            <div>
                              <div className="text-sm font-medium text-gray-900 dark:text-white">
                                {product.nameProduk}
                              </div>
                              <div className="text-xs text-gray-500 dark:text-gray-400">
                                {product.kategori
                                  ? product.kategori
                                      .replaceAll("_", " ")
                                      .replace(/\b\w/g, (char) =>
                                        char.toUpperCase()
                                      )
                                  : "No Category"}
                              </div>
                            </div>
                          </div>
                        </td>

                        <td className="py-4 px-6 whitespace-nowrap">
                          <div className="text-gray-900 dark:text-white">
                            {product.deskripsi && product.deskripsi.length > 20
                              ? `${product.deskripsi.slice(0, 25)}...`
                              : product.deskripsi}
                          </div>
                        </td>

                        <td className="py-4 px-6 whitespace-nowrap text-gray-900 dark:text-white">
                          {firstVariant.stok || 0}
                        </td>

                        <td className="py-4 px-6 whitespace-nowrap">
                          <div>
                            <div className="text-sm font-medium text-gray-900 dark:text-white">
                              Rp.{" "}
                              {firstVariant.hargaRp?.toLocaleString("id-ID") ||
                                "0"}
                            </div>
                            <div className="text-xs text-orange-500 dark:text-orange-400">
                              {firstVariant.hargaPoin?.toLocaleString(
                                "id-ID"
                              ) || "0"}{" "}
                              Poin
                            </div>
                          </div>
                        </td>

                        <td className="py-4 px-6 whitespace-nowrap">
                          <div>
                            <div className="text-sm font-medium text-gray-900 dark:text-white">
                              {firstVariant.jumlah || "0"}
                            </div>
                            <div className="text-xs text-gray-500 dark:text-gray-400">
                              {firstVariant.satuan || "N/A"}
                            </div>
                          </div>
                        </td>

                        <td className="py-4 px-6 whitespace-nowrap">
                          {product.image && (
                            <img
                              src={`${API_URL_STATIC}/${product.image}`}
                              alt={product.nameProduk}
                              className="w-10 h-10 object-cover rounded-md"
                            />
                          )}
                        </td>

                        <td className="py-4 px-6 whitespace-nowrap">
                          <div className="flex items-center gap-1">
                            <ButtonAction
                              onClick={() => openModal(product)}
                              icon={<MdRemoveRedEye />}
                              className={"bg-purple-500 hover:bg-purple-600"}
                            />
                            <ButtonAction
                              to={`/products/edit/${product.id}`}
                              icon={<MdEditSquare />}
                              className={"bg-orange-500 hover:bg-orange-600"}
                            />
                            <ButtonAction
                              onClick={() => deleteProduct(product.id)}
                              icon={<MdDelete />}
                              className={"bg-red-500 hover:bg-red-600"}
                            />
                          </div>
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan="11" className="py-12 text-center">
                      <div className="flex flex-col items-center gap-3">
                        <div className="w-16 h-16 bg-gray-100 dark:bg-[#2a2a2a] rounded-full flex items-center justify-center">
                          <AiOutlineProduct className="w-8 h-8 text-gray-400" />
                        </div>
                        <div>
                          <h3 className="text-lg font-medium text-gray-900 dark:text-white">
                            No products found
                          </h3>
                          <p className="text-sm text-gray-500 dark:text-gray-400">
                            {query
                              ? `No product match "${query}"`
                              : "Get started by adding your first product."}
                          </p>
                        </div>
                        {!query && (
                          <Button
                            text="Add First Product"
                            to="/products/add"
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
      {products.length > 0 && (
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          {/* Stats */}
          <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
            <span className="font-medium">
              Showing {page * limit + 1} to {Math.min((page + 1) * limit, rows)}{" "}
              of {rows} products
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
