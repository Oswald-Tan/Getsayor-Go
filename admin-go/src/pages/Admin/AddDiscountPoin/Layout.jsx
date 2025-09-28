import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";

const Layout = () => {
  const { id } = useParams();
  const [poin, setPoin] = useState(null);
  const [promoProductId, setPromoProductId] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const fetchPoin = async () => {
      try {
        const res = await axios.get(`${API_URL}/poin/${id}`);
        setPoin(res.data);
      } catch (error) {
        console.error("Error fetching poin:", error);
      }
    };

    fetchPoin();
  }, [id]);

  const savePoin = async (e) => {
    e.preventDefault();
    if (!promoProductId || isNaN(promoProductId)) {
      Swal.fire("Error", "Please enter a valid discount percentage", "error");
      return;
    }

    if (promoProductId < 0 || promoProductId > 100) {
      Swal.fire("Error", "Discount percentage must be between 0 and 100", "error");
      return;
    }

    try {
      await axios.post(`${API_URL}/poin/update-discount`, {
        id: poin.id,
        promoProductId: parseFloat(promoProductId),
      });
      Swal.fire("Success", "Discount added successfully", "success");
      navigate("/poin");
    } catch (error) {
      if (error.response) {
        Swal.fire("Error", error.response.data.message, "error");
      } else {
        Swal.fire("Error", "An unexpected error occurred", "error");
      }
    }
  };

  return (
    <div>
      <div className="w-full">
        <h1 className="text-2xl font-semibold text-black-100 dark:text-white">Buat Discount</h1>
        <div className="bg-white dark:bg-[#282828] p-6 rounded-lg shadow-md mt-4">
          <form onSubmit={savePoin}>
            <div className="mb-4">
              <label
                htmlFor="promoProductId"
                className="block text-sm font-medium text-gray-700 dark:text-white"
              >
                Promo Product ID (Google Play)
              </label>
              <input
                type="number"
                id="promoProductId"
                value={promoProductId}
                min="0"
                max="100"
                onChange={(e) => setPromoProductId(e.target.value)}
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

export default Layout;
