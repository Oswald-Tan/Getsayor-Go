import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import { RiCoinLine } from "react-icons/ri";

const Layout = () => {
  const [poin, setPoin] = useState(0); // Ubah ke number
  const [discountPercentage, setDiscountPercentage] = useState(0);
  const [msg, setMsg] = useState("");
  const navigate = useNavigate();

  const { id } = useParams();

  useEffect(() => {
    const getPoinById = async () => {
      try {
        const res = await axios.get(`${API_URL}/poins/${id}`);

        const poinData = res.data.data;

        setPoin(poinData.Poin || 0); // Gunakan field kapital

        // Ambil discount jika ada
        const discountValue = poinData.Discount
          ? poinData.Discount.Percentage
          : 0;

        setDiscountPercentage(discountValue);
      } catch (error) {
        if (error.response) {
          setMsg(error.response.data.message);
        }
      }
    };

    getPoinById();
  }, [id]);

  const updatePoin = async (e) => {
    e.preventDefault();
    try {
      await axios.patch(`${API_URL}/poins/${id}`, { discountPercentage });
      navigate("/poin");
      Swal.fire("Success", "Point package updated successfully", "success");
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    }
  };

  // Generate promo product ID preview
  const promoProductId =
    discountPercentage > 0
      ? `points_${discountPercentage}_${poin}`
      : "No promo";

  return (
    <div>
      <div className="w-full space-y-6">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <RiCoinLine className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Edit Poin
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Edit your poin package
              </p>
            </div>
          </div>
        </div>
        <div className="p-8 bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <form onSubmit={updatePoin}>
            <p className="text-red-500">{msg}</p>
            <div className="mb-4">
              <label
                htmlFor="poin"
                className="block text-sm font-medium text-gray-700 dark:text-white"
              >
                Points
              </label>
              <input
                type="text"
                id="poin"
                value={poin}
                readOnly
                className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
              />
              <p className="text-xs text-gray-500 mt-1">
                Product ID: points_{poin}
              </p>
            </div>
            <div className="mb-4">
              <label
                htmlFor="discountPercentage"
                className="block text-sm font-medium text-gray-700 dark:text-white"
              >
                Discount Percentage
              </label>
              <select
                id="discountPercentage"
                value={discountPercentage}
                onChange={(e) => setDiscountPercentage(Number(e.target.value))}
                className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
              >
                <option value={0}>0% (No Discount)</option>
                <option value={10}>10% Discount</option>
                <option value={20}>20% Discount</option>
                <option value={30}>30% Discount</option>
                <option value={40}>40% Discount</option>
                <option value={50}>50% Discount</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">
                Promo Product ID: {promoProductId}
              </p>
            </div>
            <button
              type="submit"
              className="text-sm py-2 px-4 bg-indigo-600 text-white font-semibold rounded-md shadow hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
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
