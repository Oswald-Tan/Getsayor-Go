import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL, API_URL_STATIC } from "../config";
import Swal from "sweetalert2";

const FormEditProduct = () => {
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
  const navigate = useNavigate();

  const { id } = useParams();

  useEffect(() => {
    const getProductById = async () => {
      try {
        const res = await axios.get(`${API_URL}/products/${id}`);
        setName(res.data.nameProduk);
        setDeskripsi(res.data.deskripsi);
        setKategori(res.data.kategori);
        setStok(res.data.stok);
        setHargaRp(res.data.hargaRp);
        setJumlah(res.data.jumlah);
        setSatuan(res.data.satuan);
        setImage(res.data.image);


        // Set imageUrl with the current image URL from the API
        setImageUrl(res.data.image ? `${API_URL_STATIC}/${res.data.image}` : "");
        console.log("Image: ", res.data.image);
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
      await axios.patch(`${API_URL}/products/${id}`, formData);
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
      <div className="w-full">
        <h1 className="text-2xl font-semibold text-black-100 dark:text-white">Edit Product</h1>
        <div className="bg-white dark:bg-[#282828] p-6 rounded-lg shadow-md mt-4">
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
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
              />
            </div>
            <div className="bg-gray-100 dark:bg-[#3f3f3f] p-5 rounded-xl w-[200px] flex justify-center">
              <img
                src={imageUrl || `${API_URL_STATIC}/${imageUrl}`} 
                alt="product"
                className="w-[150px]"
              />
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

export default FormEditProduct;
