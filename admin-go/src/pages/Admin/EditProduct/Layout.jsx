import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL, API_URL_STATIC } from "../../../config";
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
  const [imageUrl, setImageUrl] = useState("");
  const [msg, setMsg] = useState("");
  const [variantId, setVariantId] = useState(0);
  const navigate = useNavigate();

  const { id } = useParams();

  useEffect(() => {
    const getProductById = async () => {
      try {
        const res = await axios.get(`${API_URL}/products/${id}`);

        // Set data produk utama
        setName(res.data.data.NameProduk);
        setDeskripsi(res.data.data.Deskripsi);
        setKategori(res.data.data.Kategori);
        setImage(res.data.data.Image);
        setImageUrl(
          res.data.data.Image ? `${API_URL_STATIC}/${res.data.data.Image}` : ""
        );

        // Set data dari varian pertama (jika ada)
        if (
          res.data.data.ProductItems &&
          res.data.data.ProductItems.length > 0
        ) {
          const firstVariant = res.data.data.ProductItems[0];
          setStok(firstVariant.Stok.toString());
          setHargaRp(firstVariant.HargaRp.toString());
          setJumlah(firstVariant.Jumlah.toString());
          setSatuan(firstVariant.Satuan);
          setVariantId(firstVariant.ID);
        }
      } catch (error) {
        if (error.response) {
          setMsg(error.response.data.message);
        }
      }
    };

    getProductById();
  }, [id]);

  const handleImageChange = (e) => {
    const selectedImage = e.target.files[0];
    setImage(selectedImage);

    // Create a local URL to display the selected image
    if (selectedImage) {
      setImageUrl(URL.createObjectURL(selectedImage));
    }
  };

  const updateProduct = async (e) => {
    e.preventDefault();

    // Buat array variant
    const variants = [{
      id: variantId,
      stok: stok,
      hargaRp: hargaRp,
      jumlah: jumlah,
      satuan: satuan
    }];

    // Buat FormData
    const formData = new FormData();
    formData.append("nameProduk", name);
    formData.append("deskripsi", deskripsi);
    formData.append("kategori", kategori);
    formData.append("variants", JSON.stringify(variants)); // Kirim sebagai JSON string

    if (image instanceof File) {
      formData.append("image", image);
    }

    try {
      await axios.patch(`${API_URL}/products/${id}`, formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });
      navigate("/products");
      Swal.fire("Success", "Product updated successfully", "success");
    } catch (error) {
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
                Edit Product
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Edit your product information
              </p>
            </div>
          </div>
        </div>
        <div className="p-8 bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <form onSubmit={updateProduct}>
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
                  type="number"
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
                  onChange={handleImageChange}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                />
              </div>
            </div>

            <div className="bg-gray-100 dark:bg-[#3f3f3f] p-5 rounded-xl w-[200px] flex justify-center">
              {imageUrl ? (
                <img
                  src={imageUrl}
                  alt="product"
                  className="w-[150px] h-[150px] object-cover rounded-md"
                />
              ) : (
                <div className="bg-gray-200 border-2 border-dashed rounded-xl w-[150px] h-[150px] flex items-center justify-center text-gray-500">
                  No image
                </div>
              )}
            </div>
            <button
              type="submit"
              className="mt-5 text-sm py-2 px-4 bg-indigo-600 text-white font-semibold rounded-md shadow hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
            >
              Update
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Layout;