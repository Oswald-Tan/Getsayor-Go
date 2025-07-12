import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../config";
import Button from "./ui/Button";
import ButtonAction from "./ui/ButtonAction";
import { RiApps2AddFill } from "react-icons/ri";
import { MdEditSquare, MdDelete } from "react-icons/md";

const PoinList = () => {
  const [poins, setPoins] = useState([]);

  useEffect(() => {
    getPoins();
  }, []);

  const getPoins = async () => {
    try {
      const res = await axios.get(`${API_URL}/poin`);
      setPoins(res.data);
    } catch (error) {
      console.error("Error fetching data", error);
    }
  };

  const deletePoin = async (id) => {
    await axios.delete(`${API_URL}/poin/${id}`);
    getPoins();
  };

  // Format discount percentage for display
  
  return (
    <div className="">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-800 dark:text-white">Points Management</h2>
        <Button
          text="Add New"
          to="/poin/add"
          iconPosition="left"
          icon={<RiApps2AddFill />}
          width="w-[140px]"
          className="bg-purple-600 hover:bg-purple-700 text-white"
        />
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-xl shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead className="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">No</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Points</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Product ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Promo Product ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              {poins.map((poin, index) => (
                <tr key={poin.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                    <span className="font-semibold text-indigo-600 dark:text-indigo-400">
                      {poin.poin.toLocaleString()}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                    <code className="bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded">
                      {poin.productId}
                    </code>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                    {poin.promoProductId ? (
                      <code className="bg-yellow-100 dark:bg-yellow-900 px-2 py-1 rounded">
                        {poin.promoProductId}
                      </code>
                    ) : (
                      <span className="text-gray-400">-</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <ButtonAction
                        to={`/poin/edit/${poin.id}`}
                        icon={<MdEditSquare className="" />}
                        className="bg-amber-600 hover:bg-amber-700 text-white"
                        tooltip="Edit"
                      />
                      <ButtonAction
                        onClick={() => deletePoin(poin.id)}
                        icon={<MdDelete className="" />}
                        className="bg-red-600 hover:bg-red-700 text-white"
                        tooltip="Delete"
                      />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {poins.length === 0 && (
          <div className="text-center py-8">
            <div className="text-gray-500 dark:text-gray-400">
              No points packages available
            </div>
            <div className="mt-2">
              <Button
                text="Create First Package"
                to="/poin/add"
                iconPosition="left"
                icon={<RiApps2AddFill />}
                className="bg-purple-600 hover:bg-purple-700 text-white mt-4"
              />
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default PoinList;