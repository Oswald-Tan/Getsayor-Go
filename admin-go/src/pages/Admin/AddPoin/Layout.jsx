import { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import { MdOutlinePriceChange } from "react-icons/md";
import { RiCoinLine } from "react-icons/ri";

const Layout = () => {
  const [poin, setPoin] = useState("");
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);

  const savePoin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      // Konversi nilai poin menjadi integer sebelum dikirim
      await axios.post(`${API_URL}/poins`, { poin: parseInt(poin) });
      navigate("/poin");
      Swal.fire("Success", "Point package added successfully", "success");
    } catch (error) {
      if (error.response) {
        Swal.fire("Error", error.response.data.message, "error");
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      <div className="w-full">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <RiCoinLine className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Add Points
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Create a new point package
              </p>
            </div>
          </div>
        </div>
        
        <div className="p-6 mt-6 bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <form onSubmit={savePoin}>
            <div className="space-y-2">
              <label
                htmlFor="poin"
                className="block text-sm font-medium text-gray-700 dark:text-gray-300"
              >
                Points
              </label>

              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <MdOutlinePriceChange className="h-4 w-4 text-gray-400" />
                </div>
                <input
                  type="number"
                  id="poin"
                  value={poin}
                  onChange={(e) => setPoin(e.target.value)}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 text-sm"
                  min="1"
                  required
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">
                Product ID will be generated automatically: points_
                {poin || "XXXX"}
              </p>
            </div>
            {/* Action Buttons */}
            <div className="pt-6">
              <button
                type="submit"
                disabled={isLoading}
                className="flex-1 px-6 py-3 text-sm bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-medium rounded-xl shadow-lg hover:shadow-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {isLoading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                    Saving Poin...
                  </>
                ) : (
                  "Save Poin"
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Layout;
