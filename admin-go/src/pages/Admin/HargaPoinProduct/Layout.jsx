import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import ButtonAction from "../../../components/ui/ButtonAction";
import { MdEditSquare, MdOutlinePriceChange } from "react-icons/md";

const Layout = () => {
  const [hargaPoin, setHargaPoin] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    getHargaPoin();
  }, []);

  const getHargaPoin = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_URL}/settings/harga-poin`);
      setHargaPoin(res.data.hargaPoin);
    } catch (error) {
      console.error("Error fetching data", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
            <MdOutlinePriceChange className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Harga Poin
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Manage and monitor your harga poin
            </p>
          </div>
        </div>
      </div>

      {/* Table Section */}
      <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] overflow-hidden">
        {loading && (
          <div className="absolute inset-0 bg-white/50 dark:bg-[#1e1e1e]/50 flex items-center justify-center z-10">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
          </div>
        )}
        
        <div className="overflow-x-auto">
          {/* Tabel responsif */}
          <table className="w-full">
            <thead>
              <tr className="bg-gray-50 dark:bg-[#252525] border-b border-gray-200 dark:border-[#2a2a2a]">
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  #
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  Harga
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
              {hargaPoin !== null ? (
                <tr className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group">
                  <td className="py-4 px-6 whitespace-nowrap">1</td>
                  <td className="py-4 px-6 whitespace-nowrap">
                    Rp. {hargaPoin.toLocaleString()}
                  </td>
                  <td className="py-4 px-6 whitespace-nowrap">
                    <div className="flex items-center gap-1">
                      <ButtonAction
                        to={`/harga/poin/product/edit`}
                        icon={<MdEditSquare />}
                        className={"bg-orange-500 hover:bg-orange-600"}
                      />
                    </div>
                  </td>
                </tr>
              ) : (
                <tr>
                  <td colSpan="11" className="py-12 text-center">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-16 h-16 bg-gray-100 dark:bg-[#2a2a2a] rounded-full flex items-center justify-center">
                        <MdOutlinePriceChange className="w-8 h-8 text-gray-400" />
                      </div>
                      <div>
                        <h3 className="text-sm font-medium text-gray-900 dark:text-white">
                          No harga poin found
                        </h3>
                      </div>
                    </div>
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
