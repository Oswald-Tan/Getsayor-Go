import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import { PiMapPinSimpleAreaBold } from "react-icons/pi";

const Layout = () => {
  const [shippingRate, setShippingRate] = useState({ price: "" });
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const { id } = useParams();

  useEffect(() => {
    const fetchShippingRate = async () => {
      try {
        setLoading(true);
        const res = await axios.get(`${API_URL}/shipping-rates/price/${id}`);
        setShippingRate({ price: res.data.data.Price });
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchShippingRate();
  }, [id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setShippingRate((prevState) => ({
      ...prevState,
      [name]: value,
    }));
  };

  // Fungsi untuk menangani pengiriman form
  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      await axios.put(`${API_URL}/shipping-rates/${id}`, {
        Price: parseFloat(shippingRate.price), // Konversi ke float
      });

      Swal.fire("Success", "Shipping rate updated successfully", "success");
      navigate("/shipping/rates");
    } catch (err) {
      console.error(err);
      // Tampilkan pesan error spesifik dari backend
      const errorMsg =
        err.response?.data?.message || "Failed to update shipping rate";
      Swal.fire("Error", errorMsg, "error");
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <p>Loading...</p>;
  }

  return (
    <div>
      <div className="space-y-6 w-full">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <PiMapPinSimpleAreaBold className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Edit Shipping Rate
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Create a new shipping rate
              </p>
            </div>
          </div>
        </div>

        <div className="p-8 bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 dark:text-white">
                Price
              </label>
              <input
                type="number"
                name="price"
                value={shippingRate.price}
                onChange={handleChange}
                className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
              />
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
