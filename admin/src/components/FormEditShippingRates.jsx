import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../config";
import Swal from "sweetalert2";

const FormEditShippingRates = () => {
  const [shippingRate, setShippingRate] = useState({ price: "" });
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const { id } = useParams();

  useEffect(() => {
    const fetchShippingRate = async () => {
      try {
        setLoading(true);
        const res = await axios.get(`${API_URL}/shipping-rates/price/${id}`);
        setShippingRate({ price: res.data.data.price });
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
        price: shippingRate.price,
      });
      navigate("/shipping/rates");
      Swal.fire("Success", "Product updated successfully", "success");
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <p>Loading...</p>;
  }

  return (
    <div>
      <div className="w-full">
        <h1 className="text-2xl font-semibold text-black-100 dark:text-white">Edit Shipping Rate</h1>
        <div className="bg-white dark:bg-[#282828] p-6 rounded-lg shadow-md mt-4">
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

export default FormEditShippingRates;
