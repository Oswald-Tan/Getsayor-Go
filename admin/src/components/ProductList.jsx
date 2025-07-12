import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL, API_URL_STATIC } from "../config";
import Button from "./ui/Button";
import ButtonAction from "./ui/ButtonAction";
import { RiApps2AddFill } from "react-icons/ri";
import { MdEditSquare, MdDelete, MdRemoveRedEye } from "react-icons/md";
import Swal from "sweetalert2";
import ModalProduct from "./ui/ModalProduct";

const ProductList = () => {
  const [products, setProducts] = useState([]);
  const [selectedProduct, setselectedProduct] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const openModal = (products) => {
    setselectedProduct(products);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setselectedProduct(null);
    setIsModalOpen(false);
  };

  useEffect(() => {
    getProduct();
  }, []);

  const getProduct = async () => {
    try {
      const res = await axios.get(`${API_URL}/products`);
      setProducts(res.data);
      console.log(res.data);
    } catch (error) {
      console.error("Error fetching data", error);
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
        <ModalProduct products={selectedProduct} onClose={closeModal} />
      )}

      <div>
        <h2 className="text-2xl font-semibold mb-4 dark:text-white">Produk</h2>
        <Button
          text="Add New"
          to="/products/add"
          iconPosition="left"
          icon={<RiApps2AddFill />}
          width={"w-[120px]"}
          className={"bg-purple-500 hover:bg-purple-600"}
        />
        <div className="overflow-x-auto bg-white dark:bg-[#282828] rounded-xl p-4 mt-5">
          {/* Tabel responsif */}
          <table className="table-auto w-full text-left text-black-100">
            <thead>
              <tr className="text-sm dark:text-white">
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  No
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Nama Produk
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Deskripsi
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Kategori
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Stok
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Harga (Poin)
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Harga (Rp)
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Berat
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Satuan
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Image
                </th>
                <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody>
              {products.length > 0 ? (
                products.map((product, index) => (
                  <tr key={index} className="text-sm dark:text-white">
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {index + 1}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {product.nameProduk}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-normal break-words w-64 min-w-64">
                      {product.deskripsi.length > 20
                        ? `${product.deskripsi.slice(0, 25)} ...`
                        : product.deskripsi}
                    </td>

                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-normal break-words w-48 min-w-48">
                      {product.kategori
                        .replaceAll("_", " ") // Ganti underscore dengan spasi
                        .replace(/\b\w/g, (char) => char.toUpperCase())}{" "}
                      {/* Kapitalisasi setiap kata */}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-normal break-words w-24 min-w-24">
                      {product.stok}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {product.hargaPoin}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      Rp. {product.hargaRp.toLocaleString("id-ID")}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {product.jumlah}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      {product.satuan}
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      <img
                        src={`${API_URL_STATIC}/${product.image}`}
                        alt={product.nameProduk}
                        className="w-10"
                      />
                    </td>
                    <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                      <div className="flex gap-x-2">
                        <ButtonAction
                          onClick={() => openModal(product)}
                          icon={<MdRemoveRedEye />}
                          className={"bg-purple-600 hover:bg-purple-700"}
                        />
                        <ButtonAction
                          to={`/products/edit/${product.id}`}
                          icon={<MdEditSquare />}
                          className={"bg-orange-600 hover:bg-orange-700"}
                        />
                        <ButtonAction
                          onClick={() => deleteProduct(product.id)}
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
    </>
  );
};

export default ProductList;
