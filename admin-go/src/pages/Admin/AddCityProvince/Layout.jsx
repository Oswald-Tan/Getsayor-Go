import { useState } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import { useNavigate } from "react-router-dom";
import { MdDelete } from "react-icons/md";
import { PiMapPinSimpleAreaBold } from "react-icons/pi";

const Layout = () => {
  const [provinceName, setProvinceName] = useState("");
  const [cities, setCities] = useState([""]);
  const [message, setMessage] = useState("");
  const navigate = useNavigate();

  const handleProvinceChange = (e) => {
    setProvinceName(e.target.value);
  };

  const handleCityChange = (index, value) => {
    const updatedCities = [...cities];
    updatedCities[index] = value;
    setCities(updatedCities);
  };

  const addCityField = () => {
    setCities([...cities, ""]);
  };

  const removeCityField = (index) => {
    const updatedCities = cities.filter((_, i) => i !== index);
    setCities(updatedCities);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!provinceName || cities.some((city) => !city)) {
      setMessage("Please fill in all fields.");
      return;
    }

    try {
      const res = await axios.post(`${API_URL}/provinces`, {
        provinceName,
        cities,
      });

      setMessage(
        res.data.message || "Province and cities created successfully!"
      );
      setProvinceName("");
      setCities([""]);
      navigate("/city/province");
    } catch (error) {
      setMessage(error.response?.data?.message || "An error occurred.");
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
                City Province
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Create a new city province
              </p>
            </div>
          </div>
        </div>
        <div className="p-8 bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <form onSubmit={handleSubmit}>
            {message && <p className="text-red-500 mb-4">{message}</p>}

            {/* Input untuk Postal Code */}
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 dark:text-white">
                Province Name
              </label>
              <input
                type="text"
                id="provinceName"
                value={provinceName}
                onChange={handleProvinceChange}
                className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                required
              />
            </div>

            {/* Input untuk City */}
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 dark:text-white">
                Cities
              </label>
              {cities.map((city, index) => (
                <div key={index}>
                  <input
                    type="text"
                    placeholder={`City ${index + 1}`}
                    value={city}
                    onChange={(e) => handleCityChange(index, e.target.value)}
                    className="w-full px-3 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 mt-2 text-sm"
                    required
                  />
                  {cities.length > 1 && (
                    <button
                      type="button"
                      onClick={() => removeCityField(index)}
                      className="text-sm mt-2 mb-2 p-2 bg-red-600 text-white font-semibold rounded-md shadow hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                    >
                      <MdDelete />
                    </button>
                  )}
                </div>
              ))}
            </div>

            <div className="flex gap-2">
              <button
                type="button"
                onClick={addCityField}
                className="text-sm py-2 px-4 bg-orange-600 text-white font-semibold rounded-md shadow hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Add City
              </button>
              <button
                type="submit"
                className="text-sm py-2 px-4 bg-indigo-600 text-white font-semibold rounded-md shadow hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Submit
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Layout;
