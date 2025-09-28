import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import Button from "../../../components/ui/Button";
import ButtonAction from "../../../components/ui/ButtonAction";
import { RiApps2AddFill, RiCoinLine } from "react-icons/ri";
import { MdEditSquare, MdDelete } from "react-icons/md";
import { HiOutlineUsers } from "react-icons/hi";
import Poin from "../../../assets/poin_cs.png";
import Swal from "sweetalert2";

const Layout = () => {
  const [poins, setPoins] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    getPoins();
  }, []);

  const getPoins = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_URL}/poins`);

      // Pastikan mengambil data dari properti 'data' di response
      if (res.data.success && Array.isArray(res.data.data)) {
        setPoins(res.data.data);
      } else {
        console.error("Invalid data format", res.data);
        setPoins([]); // Set array kosong jika format tidak valid
      }
    } catch (error) {
      console.error("Error fetching data", error);
      setPoins([]); // Set array kosong jika error
    } finally {
      setLoading(false);
    }
  };

  const deletePoin = async (id) => {
    Swal.fire({
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc2626",
      cancelButtonColor: "#6b7280",
      confirmButtonText: "Yes, delete it!",
      customClass: {
        popup: "rounded-xl",
        confirmButton: "rounded-lg",
        cancelButton: "rounded-lg",
      },
    }).then(async (result) => {
      if (result.isConfirmed) {
        await axios.delete(`${API_URL}/poins/${id}`);
        getPoins();

        Swal.fire({
          icon: "success",
          title: "Deleted!",
          text: "Poin deleted successfully.",
          customClass: {
            popup: "rounded-xl",
            confirmButton: "rounded-lg",
          },
        });
      }
    });
  };


  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
            <RiCoinLine className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Poin Management
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Manage poin
            </p>
          </div>
        </div>
        <div>
          <Button
            text="Add New"
            to="/poin/add"
            iconPosition="left"
            icon={<RiApps2AddFill />}
            width="w-[140px]"
            className="bg-purple-600 hover:bg-purple-700 text-white"
          />
        </div>
      </div>

      <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] overflow-hidden">
        {loading && (
          <div className="absolute inset-0 bg-white/50 dark:bg-[#1e1e1e]/50 flex items-center justify-center z-10">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
          </div>
        )}
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead>
              <tr className="bg-gray-50 dark:bg-[#252525] border-b border-gray-200 dark:border-[#2a2a2a]">
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  #
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Points
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Product ID
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Promo Product ID
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
              {Array.isArray(poins) ? (
                poins.map((poin, index) => (
                  <tr
                    key={poin.ID}
                    className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group"
                  >
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="text-gray-900 dark:text-white">
                        {index + 1}
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="text-sm text-gray-900 dark:text-white font-medium flex items-center gap-1">
                        <img src={Poin} alt="Poin" className="w-4 h-4" />
                        {poin.Poin.toLocaleString()}
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="text-sm text-gray-900 dark:text-white font-medium">
                        {poin.ProductID}
                      </div>
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      {poin.PromoProductID ? (
                        <div className="text-sm text-gray-900 dark:text-white font-medium">
                          {poin.PromoProductID}
                        </div>
                      ) : (
                        <span className="text-gray-400">-</span>
                      )}
                    </td>
                    <td className="py-4 px-6 whitespace-nowrap">
                      <div className="flex space-x-1">
                        <ButtonAction
                          to={`/poin/edit/${poin.ID}`}
                          icon={<MdEditSquare className="" />}
                          className="bg-amber-500 hover:bg-amber-600 text-white"
                          tooltip="Edit"
                        />
                        <ButtonAction
                          onClick={() => deletePoin(poin.ID)}
                          icon={<MdDelete className="" />}
                          className="bg-red-500 hover:bg-red-600 text-white"
                          tooltip="Delete"
                        />
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="5" className="py-12 text-center">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-16 h-16 bg-gray-100 dark:bg-[#2a2a2a] rounded-full flex items-center justify-center">
                        <HiOutlineUsers className="w-8 h-8 text-gray-400" />
                      </div>
                      <div>
                        <h3 className="text-lg font-medium text-gray-900 dark:text-white">
                          No points packages available
                        </h3>
                      </div>
                    </div>
                    <Button
                      text="Create First Package"
                      to="/poin/add"
                      iconPosition="left"
                      icon={<RiApps2AddFill />}
                      className="bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium px-6 py-2.5 rounded-xl transition-all duration-200"
                    />
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Layout;
