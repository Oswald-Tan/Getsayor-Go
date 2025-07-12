import { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import { API_URL } from "../config";
import Swal from "sweetalert2";

const FormAddProduct = () => {
  const [name, setName] = useState("");
  const [deskripsi, setDeskripsi] = useState("");
  const [kategori, setKategori] = useState("");
  const [stok, setStok] = useState("");
  const [hargaRp, setHargaRp] = useState("");
  const [jumlah, setJumlah] = useState("");
  const [satuan, setSatuan] = useState("");
  const [image, setImage] = useState(null);
  const [msg, setMsg] = useState("");
  const navigate = useNavigate();

  const saveProduct = async (e) => {
    e.preventDefault();

    //create a formdata object untuk kirim file gambar dan data lain
    const formData = new FormData();
    formData.append("nameProduk", name);
    formData.append("deskripsi", deskripsi);
    formData.append("kategori", kategori);
    formData.append("stok", stok);
    formData.append("hargaRp", hargaRp);
    formData.append("jumlah", jumlah);
    formData.append("satuan", satuan);
    formData.append("image", image);


    try {
      await axios.post(`${API_URL}/products`, formData);
      navigate("/products");
      Swal.fire("Success", "Product added successfully", "success");
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    }
  };

    return (
      <div>
        <div className="w-full">
          <h1 className="text-2xl font-semibold text-black-100 dark:text-white">Add Product</h1>
          <div className="bg-white dark:bg-[#282828] p-6 rounded-lg shadow-md mt-4">
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
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
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
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
              />
            </div>
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
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
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
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
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
                type="text"
                id="hargaRp"
                value={hargaRp}
                onChange={(e) => setHargaRp(e.target.value)}
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
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
                type="text"
                id="jumlah"
                value={jumlah}
                onChange={(e) => setJumlah(e.target.value)}
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
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
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
              >
                <option value="">...</option>
                <option value="Gram">Gram</option>
                <option value="Kilogram">Kilogram</option>
                <option value="Ikat">Ikat</option>
                <option value="Biji">Biji</option>
              </select>
            </div>
            <div className="mb-4">
              <label htmlFor="image" className="block text-sm font-medium text-gray-700 dark:text-white">
                Product Image
              </label>
              <input
                type="file"
                id="image"
                onChange={(e) => setImage(e.target.files[0])}
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
              />
            </div>
              <button
                type="submit"
                className="text-sm py-2 px-4 bg-indigo-600 text-white font-semibold rounded-md shadow hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Save
              </button>
            </form>
          </div>
        </div>
      </div>
    );
  };
  
  export default FormAddProduct;
  