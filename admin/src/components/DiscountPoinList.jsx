import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import axios from "axios";
import { API_URL } from "../config";

const DiscountPoinList = () => {
  const [discounts, setDiscounts] = useState([]);

  useEffect(() => {
    getDiscountPoin();
  }, []);

  const getDiscountPoin = async () => {
    const res = await axios.get(`${API_URL}/discount`);
    setDiscounts(res.data);
  };

  const deleteDiscountPoin = async (id) => {
    await axios.delete(`${API_URL}/discount/${id}`);
    getDiscountPoin();
  };

  return (
    <div className="h-screen">
      <h2 className="text-2xl font-semibold mb-4 dark:text-white">Dicount Poin</h2>
      <Link
        className="bg-indigo-600 text-white font-semibold rounded-md shadow hover:bg-indigo-700 focus:outline-none px-6 py-1"
        to="/discount/poin/add"
      >
        Add New
      </Link>
      <div className="overflow-x-auto bg-white rounded-xl p-4 mt-5">
        {/* Tabel responsif */}
        <table className="table-auto w-full text-left text-black-100">
          <thead>
            <tr>
              <th className="px-4 py-2 border-b">No</th>
              <th className="px-4 py-2 border-b">Poin</th>
              <th className="px-4 py-2 border-b">Persentase</th>
              <th className="px-4 py-2 border-b">Actions</th>
            </tr>
          </thead>
          <tbody>
            {discounts.map((discount, index) => (
              <tr key={index}>
                <td className="px-4 py-2">{index + 1}</td>
                <td className="px-4 py-2">{discount.poin}</td>
                <td className="px-4 py-2">{discount.percentage}</td>
                <td className="px-4 py-2">
                  <Link
                    to={`/discount/poin/edit/${discount.id}`}
                    className="px-4 text-sm bg-blue-500 text-white rounded"
                  >
                    edit
                  </Link>
                  <button
                    onClick={() => deleteDiscountPoin(discount.id)}
                    className="px-4 text-sm bg-red-500 text-white rounded"
                  >
                    delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default DiscountPoinList;
