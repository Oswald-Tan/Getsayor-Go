import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../config"; // Pastikan Anda memiliki config.js untuk base URL
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";

const FormAddShippingRates = () => {
  const [cities, setCities] = useState([]);
  const [selectedCity, setSelectedCity] = useState("");
  const [shippingRate, setShippingRate] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    // Fetch daftar kota menggunakan Axios
    axios
      .get(`${API_URL}/provinces-cities/cities`)
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
      await axios.post(`${API_URL}/shipping-rates`, {
        cityId: selectedCity,
        price: shippingRate,
      });

      Swal.fire("Success", "Shipping rate added successfully", "success");
      navigate("/shipping/rates");
    } catch (error) {
      console.error("Error adding shipping rate:", error);
      Swal.fire("Error", "Failed to add shipping rate", "error");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="w-full">
        <h1 className="text-2xl font-semibold text-gray-800 mb-6 dark:text-white">
          Shipping Rate
        </h1>
        <div className="bg-white dark:bg-[#282828] p-6 rounded-lg shadow-md">
          <form onSubmit={handleAddShippingRate}>
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 dark:text-white">
                City
              </label>
              <select
                value={selectedCity}
                onChange={handleCityChange}
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
              >
                <option value="">-- Select City --</option>
                {cities.map((city) => (
                  <option key={city.id} value={city.id}>
                    {city.name}
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
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
                required
              />
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

export default FormAddShippingRates;
