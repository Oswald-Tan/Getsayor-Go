import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import { PiMapPinSimpleAreaBold } from "react-icons/pi";

const Layout = () => {
  const [cities, setCities] = useState([]);
  const [selectedCity, setSelectedCity] = useState("");
  const [shippingRate, setShippingRate] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    // Fetch daftar kota menggunakan Axios
    axios
      .get(`${API_URL}/provinces/cities`)
      .then((res) => setCities(res.data.data))
      .catch((error) => console.error("Error fetching cities:", error));
  }, []);

  const handleCityChange = async (e) => {
    const cityId = e.target.value;
    setSelectedCity(cityId);
  };

  const handleAddShippingRate = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      // Konversi cityId ke number
      await axios.post(`${API_URL}/shipping-rates`, {
        cityId: Number(selectedCity), // Konversi ke number
        price: Number(shippingRate), // Konversi ke number
      });

      Swal.fire("Success", "Shipping rate added successfully", "success");
      navigate("/shipping/rates");
    } catch (error) {
      console.error("Error adding shipping rate:", error);

      // Tampilkan pesan error spesifik dari backend
      const errorMessage =
        error.response?.data?.message || "Failed to add shipping rate";
      Swal.fire("Error", errorMessage, "error");
    } finally {
      setLoading(false);
    }
  };

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
                Shipping Rate
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Create a new shipping rate
              </p>
            </div>
          </div>
        </div>

        <div className="p-8 bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <form onSubmit={handleAddShippingRate}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 dark:text-white">
                  City
                </label>
                <select
                  value={selectedCity}
                  onChange={handleCityChange}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                >
                  <option value="">-- Select City --</option>
                  {cities.map((city) => (
                    <option key={city.ID} value={city.ID}>
                      {city.Name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 dark:text-white">
                  Shipping Rate
                </label>
                <input
                  type="number"
                  value={shippingRate}
                  onChange={(e) => setShippingRate(e.target.value)}
                  className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                  required
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="text-sm py-2 px-4 bg-indigo-600 text-white font-semibold rounded-md shadow hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
            >
              {loading ? "Adding..." : "Add Shipping Rate"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Layout;
