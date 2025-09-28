import { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import { AiOutlineProduct } from "react-icons/ai";

const Layout = () => {
  const [name, setName] = useState("");
  const [deskripsi, setDeskripsi] = useState("");
  const [kategori, setKategori] = useState("");
  const [stok, setStok] = useState("");
  const [hargaRp, setHargaRp] = useState("");
  const [jumlah, setJumlah] = useState("");
  const [satuan, setSatuan] = useState("");
  const [image, setImage] = useState(null);
  const [msg, setMsg] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const saveProduct = async (e) => {
    e.preventDefault();
    setLoading(true);

    // Buat objek variant
    const variant = {
      stok: stok,
      hargaRp: hargaRp,
      jumlah: jumlah,
      satuan: satuan,
    };

    // Buat array variants
    const variants = [variant];

    //create a formdata object untuk kirim file gambar dan data lain
    const formData = new FormData();
    formData.append("nameProduk", name);
    formData.append("deskripsi", deskripsi);
    formData.append("kategori", kategori);

    // Kirim variants sebagai JSON string
    formData.append("variants", JSON.stringify(variants));

    formData.append("image", image);

    try {
      await axios.post(`${API_URL}/products`, formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });
      setLoading(false);
      navigate("/products");
      Swal.fire("Success", "Product added successfully", "success");
    } catch (error) {
      setLoading(false);
      if (error.response) {
        setMsg(error.response.data.message);
      }
    }
  };

  return (
    <div>
      <div className="space-y-6 w-full">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <AiOutlineProduct className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Add Product
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Create a new product for your store
              </p>
            </div>
          </div>
        </div>

        <div className="p-8 bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <form onSubmit={saveProduct}>
            <p className="text-red-500">{msg}</p>
            <div className="mb-4">
              <label
                htmlFor="name"
                className="block text-sm font-medium text-gray-700 dark:text-white"
              >
                Name
              </label>
              <input
                type="text"
                id="name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
              />
            </div>
            <div className="mb-4">
              <label
                htmlFor="deskripsi"
                className="block text-sm font-medium text-gray-700 dark:text-white"
              >
                Deskripsi
              </label>
              <textarea
                type="text"
                id="deskripsi"
                rows="4"
                value={deskripsi}
                onChange={(e) => setDeskripsi(e.target.value)}
                className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-x-6">
              <div className="mb-4">
                <label
                  htmlFor="kategori"
                  className="block text-sm font-medium text-gray-700 dark:text-white"
                >
                  Kategori
                </label>
                <select
                  id="kategori"
                  value={kategori}
                  onChange={(e) => setKategori(e.target.value)}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                >
                  <option value="">...</option>
                  <option value="Vegetables">Sayuran</option>
                  <option value="Spices">Rempah & Bumbu</option>
                  <option value="Fruits">Buah-buahan</option>
                  <option value="Seafood">Seafood</option>
                  <option value="Meat_poultry">Daging & Unggas</option>
                  <option value="Tubers">Umbi-umbian</option>
                  <option value="Plant_based_protein">Protein Nabati</option>
                </select>
              </div>
              <div className="mb-4">
                <label
                  htmlFor="stok"
                  className="block text-sm font-medium text-gray-700 dark:text-white"
                >
                  Stok
                </label>
                <input
                  type="number"
                  id="stok"
                  value={stok}
                  onChange={(e) => setStok(e.target.value)}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                />
              </div>
              <div className="mb-4">
                <label
                  htmlFor="hargaRp"
                  className="block text-sm font-medium text-gray-700 dark:text-white"
                >
                  Harga (Rupiah)
                </label>
                <input
                  type="number" // Ubah ke number
                  id="hargaRp"
                  value={hargaRp}
                  onChange={(e) => setHargaRp(e.target.value)}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                />
              </div>

              <div className="mb-4">
                <label
                  htmlFor="jumlah"
                  className="block text-sm font-medium text-gray-700 dark:text-white"
                >
                  Jumlah
                </label>
                <input
                  type="number"
                  id="jumlah"
                  value={jumlah}
                  onChange={(e) => setJumlah(e.target.value)}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                />
              </div>
              <div className="mb-4">
                <label
                  htmlFor="satuan"
                  className="block text-sm font-medium text-gray-700 dark:text-white"
                >
                  Satuan
                </label>
                <select
                  id="satuan"
                  value={satuan}
                  onChange={(e) => setSatuan(e.target.value)}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                >
                  <option value="">...</option>
                  <option value="gram">Gram</option>
                  <option value="kilogram">Kilogram</option>
                  <option value="ikat">Ikat</option>
                  <option value="biji">Biji</option>
                  <option value="buah">Buah</option>
                  <option value="pcs">Pcs</option>
                </select>
              </div>

              <div className="mb-4">
                <label
                  htmlFor="image"
                  className="block text-sm font-medium text-gray-700 dark:text-white"
                >
                  Product Image
                </label>
                <input
                  type="file"
                  id="image"
                  onChange={(e) => setImage(e.target.files[0])}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                />
              </div>
            </div>

            <button
              type="submit"
              className="text-sm py-2 px-4 bg-indigo-600 text-white font-semibold rounded-md shadow hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
            >
              {loading ? "Loading..." : "Save"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Layout;