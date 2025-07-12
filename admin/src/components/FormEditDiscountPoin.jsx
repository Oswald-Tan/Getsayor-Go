import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../config";
import Swal from "sweetalert2";

const FormEditDiscountPoin = () => {
  const [poinId, setPoinId] = useState("");
  const [promoProductId, setPromoProductId] = useState("");
  const [poins, setPoins] = useState([]);
  const [msg, setMsg] = useState("");
  const navigate = useNavigate();
  const { id } = useParams();

  // Ambil data poin untuk dropdown
  const getPoins = async () => {
    try {
      const res = await axios.get(`${API_URL}/poin`);
      setPoins(res.data);
    } catch (error) {
      console.error("Error fetching poins:", error);
    }
  };

  const getDiscountById = async () => {
    try {
      const res = await axios.get(`${API_URL}/discount/${id}`);
      setPoinId(res.data.poinId);
      setPromoProductId(res.data.promoProductId);
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    }
  };

  useEffect(() => {
    getPoins();
    getDiscountById();
  }, [id]);

  const updateDiscountPoin = async (e) => {
    e.preventDefault();
    try {
      await axios.patch(`${API_URL}/discount/${id}`, { poinId, promoProductId });
      navigate("/discount/poin");
      Swal.fire("Success", "Discount updated successfully", "success");
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    }
  };

  return (
    <div>
      <div className="w-full">
        <h1 className="text-2xl font-semibold text-black-100 dark:text-white">Edit Discount</h1>
        <div className="bg-white p-6 rounded-lg shadow-md mt-4">
          <form onSubmit={updateDiscountPoin}>
            <p className="text-red-500">{msg}</p>
            <div className="mb-4">
              <label htmlFor="poin" className="block text-sm font-medium text-gray-700">
                Poin
              </label>
              <select
                id="poin"
                value={poinId}
                onChange={(e) => setPoinId(e.target.value)}
                className="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option value="">...</option>
                {poins.map((poin) => (
                  <option key={poin.id} value={poin.id}>
                    {poin.poin}
                  </option>
                ))}
              </select>
            </div>
            <div className="mb-4">
              <label
                htmlFor="promoProductId"
                className="block text-sm font-medium text-gray-700"
              >
                Promo Product ID (Google Play)
              </label>
              <input
                type="text"
                id="promoProductId"
                value={promoProductId}
                onChange={(e) => setPromoProductId(e.target.value)}
                className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
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

export default FormEditDiscountPoin;
