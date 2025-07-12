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
      .replace(/\u00A0/g, ""); // Menghapus spasi non-breaking yang kadang muncul
  };
  

  return (
    <div className="bg-white dark:bg-[#282828] rounded-3xl p-5 md:w-[400px] w-full">
      <div className="flex justify-between items-center">
        <div className="border border-gray-200 dark:text-white rounded-full w-8 h-8 flex items-center justify-center">
          <PiArrowBendRightDownFill />
        </div>
        <div>
          <div className="flex items-center relative">
            <select
              value={period}
              onChange={(e) => setPeriod(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-full text-xs appearance-none pr-7 cursor-pointer"
            >
              <option value="weekly">Weekly</option>
              <option value="monthly">Monthly</option>
              <option value="yearly">Yearly</option>
            </select>
            <span className="absolute right-3 text-gray-500">
              <MdKeyboardArrowDown />
            </span>
          </div>
        </div>
      </div>
      <div>
        <p className="text-xs text-gray-500 dark:text-white mt-5">Total Top Up</p>
        {loading ? (
          <p className="text-xl font-semibold mt-1 text-black dark:text-white">
            Loading...
          </p>
        ) : (
          <p className="mt-1 font-semibold text-xl text-black dark:text-white">
            <span className="text-[#a2e936] text-xs">Rp </span>
            {formatCurrency(total).replace("IDR", "").trim()}
          </p>
        )}
      </div>
    </div>
  );
};

export default CardTotalTopUp;
