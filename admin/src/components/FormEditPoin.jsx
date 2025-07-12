import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../config";
import Swal from "sweetalert2";

const FormEditPoin = () => {
  const [poin, setPoin] = useState("");
  const [discountPercentage, setDiscountPercentage] = useState(0);
  const [msg, setMsg] = useState("");
  const navigate = useNavigate();

  const { id } = useParams();

  useEffect(() => {
    const getPoinById = async () => {
      try {
        const res = await axios.get(`${API_URL}/poin/${id}`);
        setPoin(res.data.poin);
        setDiscountPercentage(res.data.discountPercentage || 0);
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
      await axios.patch(`${API_URL}/poin/${id}`, { discountPercentage });
      navigate("/poin");
      Swal.fire("Success", "Product updated successfully", "success");
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    }
  };

  // Generate promo product ID preview
  const promoProductId = discountPercentage > 0 
    ? `points_${discountPercentage}_${poin}` 
    : "Tidak ada promo";

  return (
    <div>
      <div className="w-full">
        <h1 className="text-2xl font-semibold text-black-100 dark:text-white">
          Edit Product
        </h1>
        <div className="bg-white dark:bg-[#282828] p-6 rounded-lg shadow-md mt-4">
          <form onSubmit={updatePoin}>
            <p className="text-red-500">{msg}</p>
            <div className="mb-4">
              <label
                htmlFor="poin"
                className="block text-sm font-medium text-gray-700 dark:text-white"
              >
                Poin
              </label>
              <input
                type="text"
                id="poin"
                value={poin}
                readOnly
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f] bg-gray-100"
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
                onChange={(e) => setDiscountPercentage(parseInt(e.target.value))}
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
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

export default FormEditPoin;