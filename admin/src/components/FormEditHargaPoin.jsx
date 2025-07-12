import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../config";
import Swal from "sweetalert2";

const FormEditHargaPoin = () => {
  const [harga, setHarga] = useState("");
  const [msg, setMsg] = useState("");
  const navigate = useNavigate();

  const { id } = useParams();

  useEffect(() => {
    const getProductById = async () => {
        try {
          const res = await axios.get(`${API_URL}/harga/${id}`);
          setHarga(res.data.harga);
        } catch (error) {
          if (error.response) {
            setMsg(error.response.data.message);
          }
        }
    }

    getProductById();
  }, [id]);

  const updateProduct = async (e) => {
    e.preventDefault();
    try {
      await axios.patch(`${API_URL}/harga/${id}`, { harga });
      navigate("/harga/poin");
      Swal.fire("Success", "Product updated successfully", "success");
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    }
  };

    return (
      <div>
        <div className="w-full">
          <h1 className="text-2xl font-semibold text-black-100 dark:text-white">Edit Harga Poin</h1>
          <div className="bg-white dark:bg-[#282828] p-6 rounded-lg shadow-md mt-4">
            <form onSubmit={updateProduct}>
            <p className="text-red-500">{msg}</p>
              <div className="mb-4">
                <label htmlFor="harga" className="block text-sm font-medium text-gray-700 dark:text-white">
                  Harga
                </label>
                <input
                  type="text"
                  id="harga"
                  value={harga}
                  onChange={(e) => setHarga(e.target.value)}
                  className="mt-1 block w-full px-3 py-2 border dark:text-white border-gray-300 dark:border-[#575757] rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-[#3f3f3f]"
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
  
  export default FormEditHargaPoin;
  