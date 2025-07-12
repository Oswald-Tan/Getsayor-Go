import { useEffect, useState } from "react";
import axios from "axios";
import { PiArrowBendRightDownFill } from "react-icons/pi";
import { MdKeyboardArrowDown } from "react-icons/md";
import { API_URL } from "../config";

const CardTotalTopUp = () => {
  const [period, setPeriod] = useState("weekly");
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchTotal = async () => {
      try {
        setLoading(true);
        const res = await axios.get(`${API_URL}/topup/total/${period}`);
        setTotal(res.data.total);
      } catch (error) {
        console.error("Error fetching total:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchTotal();
  }, [period]);

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat("id-ID", {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    })
      .format(amount)
      .replace(/\u00A0/g, "");
  };

  const getPeriodLabel = () => {
    switch(period) {
      case "weekly": return "Mingguan";
      case "monthly": return "Bulanan"; 
      case "yearly": return "Tahunan";
      default: return "Mingguan";
    }
  };

  return (
    <div className="group relative bg-gradient-to-br from-white to-gray-50 dark:from-gray-800 dark:to-gray-900 rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 border border-gray-100 dark:border-gray-700 md:w-[400px] w-full overflow-hidden">
      {/* Background decoration */}
      <div className="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-emerald-100 to-emerald-200 dark:from-emerald-900/20 dark:to-emerald-800/20 rounded-full blur-3xl opacity-30 transform translate-x-16 -translate-y-16"></div>
      
      <div className="">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <div className="relative">
            <div className="bg-gradient-to-r from-emerald-500 to-emerald-600 rounded-xl w-12 h-12 flex items-center justify-center text-white shadow-lg shadow-emerald-500/25 group-hover:shadow-emerald-500/40 transition-all duration-300">
              <PiArrowBendRightDownFill className="text-lg" />
            </div>
            <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-emerald-400 rounded-full animate-pulse"></div>
          </div>
          
          <div className="relative">
            <select
              value={period}
              onChange={(e) => setPeriod(e.target.value)}
              className="bg-white dark:bg-gray-800 px-4 py-2.5 border border-gray-200 dark:border-gray-600 rounded-xl text-sm font-medium text-gray-700 dark:text-gray-300 appearance-none pr-10 cursor-pointer hover:border-emerald-300 dark:hover:border-emerald-600 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all duration-200 shadow-sm"
            >
              <option value="weekly">Mingguan</option>
              <option value="monthly">Bulanan</option>
              <option value="yearly">Tahunan</option>
            </select>
            <div className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 pointer-events-none">
              <MdKeyboardArrowDown className="text-lg" />
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
              Total Top Up {getPeriodLabel()}
            </p>
            <div className="flex items-center space-x-1">
              <div className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse"></div>
              <span className="text-xs font-medium text-emerald-600 dark:text-emerald-400">
                {loading ? "Loading..." : "Updated"}
              </span>
            </div>
          </div>
          
          {loading ? (
            <div className="space-y-2">
              <div className="h-8 bg-gray-200 dark:bg-gray-700 rounded-lg animate-pulse"></div>
              <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded-lg animate-pulse w-1/2"></div>
            </div>
          ) : (
            <div className="space-y-1">
              <div className="flex items-end space-x-2">
                <span className="text-base font-semibold text-emerald-600 dark:text-emerald-400">
                  Rp
                </span>
                <p className="text-3xl font-bold text-gray-900 dark:text-white leading-none">
                  {formatCurrency(total).replace("IDR", "").trim()}
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Bottom accent */}
        <div className="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-emerald-500 to-emerald-600 rounded-b-2xl"></div>
      </div>
    </div>
  );
};

export default CardTotalTopUp;