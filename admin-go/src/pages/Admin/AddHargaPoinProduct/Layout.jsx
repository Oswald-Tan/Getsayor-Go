import { useEffect, useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import { AiOutlineProduct } from "react-icons/ai";

const Layout = () => {
  const [hargaPoin, setHargaPoin] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const fetchHargaPoin = async () => {
      try {
        const res = await axios.get(`${API_URL}/settings/harga-poin`);
        setHargaPoin(res.data.hargaPoin);
      } catch (error) {
        console.error(error);
      }
    };

    fetchHargaPoin();
  }, []);

  const saveHargaPoin = async (e) => {
    e.preventDefault();
    try {
      // Konversi hargaPoin ke number
      const hargaPoinNumber = Number(hargaPoin);

      await axios.post(`${API_URL}/settings/harga-poin`, {
        hargaPoin: hargaPoinNumber, // Kirim sebagai number
      });

      navigate("/harga/poin/product");
      Swal.fire("Success", "Harga Poin added successfully", "success");
    } catch (error) {
      if (error.response) {
        console.error(error.response.data);
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
                Harga Poin Prodcut
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Edit your Harga Poin
              </p>
            </div>
          </div>
        </div>
        <div className="p-8 bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <form onSubmit={saveHargaPoin}>
            <div className="mb-4">
              <label
                htmlFor="harga"
                className="block text-sm font-medium text-gray-700 dark:text-white"
              >
                Harga 1 Poin (Rp)
              </label>
              <input
                type="number"
                id="harga"
                value={hargaPoin}
                onChange={(e) => setHargaPoin(e.target.value)}
                className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
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

export default Layout;
