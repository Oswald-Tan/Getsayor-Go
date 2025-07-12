import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../config";
import ButtonAction from "./ui/ButtonAction";
import { MdDelete } from "react-icons/md";
import Button from "./ui/Button";
import { RiApps2AddFill } from "react-icons/ri";
import Swal from "sweetalert2";

const CityProvinceList = () => {
  const [provinces, setProvinces] = useState([]);

  // Fetch all provinces and cities
  const fetchProvinces = async () => {
    try {
      const res = await axios.get(`${API_URL}/provinces-cities`);
      setProvinces(res.data.data);
    } catch (error) {
      console.error(
        "Error fetching data",
        error.response?.data?.message || error.message
      );
    }
  };

  // Delete a province or city
  const handleDeleteArea = async (id) => {
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
        await axios.delete(`${API_URL}/provinces-cities/${id}`);
        Swal.fire("Deleted!", "The province has been deleted.", "success");
        fetchProvinces();
      } catch (error) {
        console.error(
          "Failed to delete province:",
          error.response?.data?.message || error.message
        );
        Swal.fire(
          "Failed!",
          "There was an error while deleting the area.",
          "error"
        );
      }
    } else {
      Swal.fire("Cancelled", "Your province is safe.", "info");
    }
  };

  useEffect(() => {
    fetchProvinces();
  }, []);

  return (
    <div>
      <h2 className="text-2xl font-semibold mb-4 dark:text-white">City Province</h2>
      <Button
        text="Add New"
        to="/city/province/add"
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
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Province Name</th>
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">City Names</th>
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">Actions</th>
            </tr>
          </thead>
          <tbody>
            {provinces.length > 0 ? (
              provinces.map((province, index) => (
                <tr key={province.id} className="text-sm dark:text-white">
                  <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{index + 1}</td>
                  <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">{province.name}</td>
                  <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                    {province.cities.length > 0 ? (
                      <ul>
                        {province.cities.map((city) => (
                          <li key={city.id}>{city.name}</li>
                        ))}
                      </ul>
                    ) : (
                      <span className="text-gray-500">No cities</span>
                    )}
                  </td>
                  <td className="px-4 py-2 border-b dark:border-[#3f3f3f]">
                    <div className="flex gap-x-2">
                      {/* <ButtonAction
                        to={`/supported/area/edit/${province.id}`}
                        icon={<MdEditSquare />}
                        className={"bg-orange-600 hover:bg-orange-700"}
                      /> */}
                      <ButtonAction
                        onClick={() => handleDeleteArea(province.id)}
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

export default CityProvinceList;
