import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";

const Layout = () => {
  const [harga, setHarga] = useState("");
  const [msg, setMsg] = useState("");
  const navigate = useNavigate();

  const { id } = useParams();

  useEffect(() => {
    const getProductById = async () => {
        try {
          const res = await axios.get(`${API_URL}/harga-poin/${id}`);
          setHarga(res.data.harga);
          console.log(res.data);
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
      await axios.patch(`${API_URL}/harga-poin/${id}`, { harga });
      navigate("/harga/poin");
      Swal.fire("Success", "Product updated successfully", "success");
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    }
  };

    return (
      <div className="bg-gray-100">
        <div className="w-full">
          <h1 className="text-2xl font-semibold text-black-100 dark:text-white">Edit Harga Product</h1>
          <div className="bg-white p-6 rounded-lg shadow-md mt-4">
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
  