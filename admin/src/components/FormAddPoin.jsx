import { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import { API_URL } from "../config";
import Swal from "sweetalert2";

const FormAddHargaPoin = () => {
  const [poin, setPoin] = useState("");
  const navigate = useNavigate();

  const savePoin = async (e) => {
    e.preventDefault();
    try {
      await axios.post(`${API_URL}/poin`, { poin });
      navigate("/poin");
      Swal.fire("Success", "Product added successfully", "success");
    } catch (error) {
      if (error.response) {
        Swal.fire("Error", error.response.data.message, "error");
      }
    }
  };

  return (
    <div>
      <div className="w-full">
        <h1 className="text-2xl font-semibold text-black-100 dark:text-white">Add Points</h1>
        <div className="bg-white dark:bg-[#282828] p-6 rounded-lg shadow-md mt-4">
          <form onSubmit={savePoin}>
            <div className="mb-4">
              <label
                htmlFor="poin"
                className="block text-sm font-medium text-gray-700 dark:text-white"
              >
                Points
              </label>
              <input
                type="number"
                id="poin"
                value={poin}
                onChange={(e) => setPoin(e.target.value)}
                className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
                min="1"
                required
              />
              <p className="text-xs text-gray-500 mt-1">
                Product ID akan otomatis dibuat: points_{poin || 'XXXX'}
              </p>
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

export default FormAddHargaPoin;