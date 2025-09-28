import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import ButtonAction from "../../../components/ui/ButtonAction";
import { MdDelete } from "react-icons/md";
import Button from "../../../components/ui/Button";
import { RiApps2AddFill } from "react-icons/ri";
import Swal from "sweetalert2";
import { PiMapPinSimpleAreaBold } from "react-icons/pi";

const Layout = () => {
  const [provinces, setProvinces] = useState([]);
  const [loading, setLoading] = useState(false);

  // Fetch all provinces and cities
  const fetchProvinces = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_URL}/provinces`);

      // Map the API response to match expected field names
      const mappedProvinces = res.data.data.map((province) => ({
        id: province.ID,
        name: province.Name,
        cities: province.Cities.map((city) => ({
          id: city.ID,
          name: city.Name,
          provinceId: city.ProvinceID,
        })),
      }));

      setProvinces(mappedProvinces);
    } catch (error) {
      console.error(
        "Error fetching data",
        error.response?.data?.message || error.message
      );
    } finally {
      setLoading(false);
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
        await axios.delete(`${API_URL}/provinces/${id}`);
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
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
            <PiMapPinSimpleAreaBold className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              City Province
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Manage and monitor your city province
            </p>
          </div>
        </div>

        <Button
          text="Add New"
          to="/city/province/add"
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
                  #
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  Province Name
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  City Names
                </th>
                <th className="text-left py-4 px-6 text-sm font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-[#2a2a2a]">
              {provinces.length > 0 ? (
                provinces.map((province, index) => (
                  <tr
                    key={province.id}
                    className="text-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors duration-150 group"
                  >
                    <td className="py-4 px-6 font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                      {index + 1}
                    </td>
                    <td className="py-4 px-6 font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                      {province.name}
                    </td>
                    <td className="py-4 px-6 font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                      {province.cities && province.cities.length > 0 ? (
                        <ul>
                          {province.cities.map((city) => (
                            <li key={city.id}>{city.name}</li>
                          ))}
                        </ul>
                      ) : (
                        <span className="text-gray-500">No cities</span>
                      )}
                    </td>
                    <td className="py-4 px-6 font-semibold text-gray-900 dark:text-white whitespace-nowrap">
                      <div className="flex items-center gap-1">
                        <ButtonAction
                          onClick={() => handleDeleteArea(province.id)}
                          icon={<MdDelete />}
                          className={"bg-red-500 hover:bg-red-600"}
                        />
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="11" className="py-12 text-center">
                    <div className="flex flex-col items-center gap-3">
                      <div className="w-16 h-16 bg-gray-100 dark:bg-[#2a2a2a] rounded-full flex items-center justify-center">
                        <PiMapPinSimpleAreaBold className="w-8 h-8 text-gray-400" />
                      </div>
                      <div>
                        <h3 className="text-sm font-medium text-gray-900 dark:text-white">
                          No city province found
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
