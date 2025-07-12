import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../config";
import ButtonAction from "./ui/ButtonAction";
import { MdDelete, MdEditSquare } from "react-icons/md";
import Button from "./ui/Button";
import { RiApps2AddFill } from "react-icons/ri";
import Swal from "sweetalert2";

const ShippingRatesList = () => {
  const [shippingRate, setShippingRate] = useState([]);

  //fetch all shipping rates
  const fetchShippingRates = async () => {
    try {
      const res = await axios.get(`${API_URL}/shipping-rates`);
      setShippingRate(res.data.data);
    } catch (error) {
      console.error(
        "Error fetching data",
        error.response?.data?.message || error.message
      );
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
        Swal.fire(
          "Deleted!",
          "The shipping rate has been deleted.",
          "success"
        );
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
    <div>
      <h2 className="text-2xl font-semibold mb-4 dark:text-white">Shipping Rates</h2>
      <Button
        text="Add New"
        to="/shipping/rates/add"
        iconPosition="left"
        icon={<RiApps2AddFill />}
        width={"w-[120px]"}
        className={"bg-purple-500 hover:bg-purple-600"}
      />

      <div className="mt-5 overflow-x-auto bg-white dark:bg-[#282828] rounded-xl p-4">
        <table className="table-auto w-full text-left text-black-100">
          <thead>
            <tr className="text-sm dark:text-white">
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">No</th>
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Kota</th>
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Ongkos Kirim</th>
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Actions</th>
            </tr>
          </thead>
          <tbody>
            {shippingRate.length > 0 ? (
              shippingRate.map((shipping, index) => (
                <tr key={shipping.id} className="text-sm dark:text-white">
                  <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{index + 1}</td>
                  <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{shipping['City ']?.name}</td>
                  <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Rp. {shipping.price.toLocaleString("id-ID")}</td>
                  <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                    <div className="flex gap-x-2">
                      <ButtonAction
                        to={`/shipping/rates/edit/${shipping.id}`}
                        icon={<MdEditSquare />}
                        className={"bg-orange-600 hover:bg-orange-700"}
                      />
                      <ButtonAction
                        onClick={() => handleDeleteShippingRate(shipping.id)}
                        icon={<MdDelete />}
                        className={"bg-red-600 hover:bg-red-700"}
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
  );
};

export default ShippingRatesList;
