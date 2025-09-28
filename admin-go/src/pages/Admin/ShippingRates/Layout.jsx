import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import ButtonAction from "../../../components/ui/ButtonAction";
import { MdDelete, MdEditSquare } from "react-icons/md";
import Button from "../../../components/ui/Button";
import { RiApps2AddFill } from "react-icons/ri";
import Swal from "sweetalert2";
import { PiMapPinSimpleAreaBold } from "react-icons/pi";

const Layout = () => {
  const [shippingRate, setShippingRate] = useState([]);
  const [loading, setLoading] = useState(false);

  //fetch all shipping rates
  const fetchShippingRates = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_URL}/shipping-rates`);
      setShippingRate(res.data.data);
    } catch (error) {
      console.error(
        "Error fetching data",
        error.response?.data?.message || error.message
      );
    } finally {
      setLoading(false);
    }
  };

  //delete a shipping rate
  const handleDeleteShippingRate = async (id) => {
    const result = await Swal.fire({
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, delete it!",
      cancelButtonText: "Cancel",
      reverseButtons: true,
    });

    if (result.isConfirmed) {
      try {
        await axios.delete(`${API_URL}/shipping-rates/${id}`);
        Swal.fire("Deleted!", "The shipping rate has been deleted.", "success");
        fetchShippingRates();
      } catch (error) {
        console.error(
          "Failed to delete shipping rate:",
          error.response?.data?.message || error.message
        );
        Swal.fire(
          "Failed!",
          "There was an error while deleting the shipping rate.",
          "error"
        );
      }
    } else {
      Swal.fire("Cancelled", "Your shipping rate is safe.", "info");
    }
  };

  useEffect(() => {
    fetchShippingRates();
  }, []);

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
            <PiMapPinSimpleAreaBold className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Shipping Rates
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Manage and monitor your shipping rates
            </p>
          </div>
        </div>

        <Button
          text="Add New"
          to="/shipping/rates/add"
          iconPosition="left"
          icon={<RiApps2AddFill />}
          width={"w-[120px]"}
          className={"bg-purple-500 hover:bg-purple-600"}
        />
      </div>

      {/* Table Section */}
      <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-sm border border-gray-200 dark:border-[#2a2a2a] overflow-hidden">
        {loading && (
          <div className="absolute inset-0 bg-white/50 dark:bg-[#1e1e1e]/50 flex items-center justify-center z-10">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-gray-50 dark:bg-[#252525] border-b border-gray-200 dark:border-[#2a2a2a]">
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  No
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  Kota
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  Ongkos Kirim
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
              {shippingRate.length > 0 ? (
                shippingRate.map((shipping, index) => (
                  <tr
                    key={shipping.ID}
                    className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group"
                  >
                    <td className="py-4 px-6 text-gray-900 dark:text-white whitespace-nowrap">
                      {index + 1}
                    </td>
                    <td className="py-4 px-6 text-gray-900 dark:text-white whitespace-nowrap">
                      {shipping.City?.Name}
                    </td>
                    <td className="py-4 px-6 text-gray-900 dark:text-white whitespace-nowrap">
                      Rp. {shipping.Price?.toLocaleString("id-ID")}
                    </td>
                    <td className="py-4 px-6 text-gray-900 dark:text-white whitespace-nowrap">
                      <div className="flex items-center gap-1">
                        <ButtonAction
                          to={`/shipping/rates/edit/${shipping.ID}`}
                          icon={<MdEditSquare />}
                          className={"bg-orange-500 hover:bg-orange-600"}
                        />
                        <ButtonAction
                          onClick={() => handleDeleteShippingRate(shipping.ID)}
                          icon={<MdDelete />}
                          className={"bg-red-500 hover:bg-red-600"}
                        />
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td
                    colSpan="4"
                    className="px-4 py-2 text-center text-gray-500 text-sm"
                  >
                    No data available
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
