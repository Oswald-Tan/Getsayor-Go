import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import Button from "../../../components/ui/Button";
import ButtonAction from "../../../components/ui/ButtonAction";
import { RiApps2AddFill } from "react-icons/ri";
import { MdEditSquare, MdDelete } from "react-icons/md";
import { AiOutlineProduct } from "react-icons/ai";

const Layout = () => {
  const [hargas, setHargas] = useState([]);

  useEffect(() => {
    getHargaPoin();
  }, []);

  const getHargaPoin = async () => {
    const res = await axios.get(`${API_URL}/harga`);
    setHargas(res.data);
    console.log(res.data);
  };

  const deleteHargaPoin = async (id) => {
    await axios.delete(`${API_URL}/harga/${id}`);
    getHargaPoin();

    Swal.fire({
      icon: "success",
      title: "Success",
      text: "User deleted successfully",
    });
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
            <AiOutlineProduct className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Harga Poin
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Manage and monitor your poin
            </p>
          </div>
        </div>
      </div>
      <Button
        text="Add New"
        to="/harga/poin/add"
        iconPosition="left"
        icon={<RiApps2AddFill />}
        width={"w-[120px] "}
        className={"bg-purple-500 hover:bg-purple-600"}
      />
      <div className="mt-5 overflow-x-auto bg-white dark:bg-[#282828] rounded-xl p-4">
        {/* Tabel responsif */}
        <table className="table-auto w-full text-left text-black-100">
          <thead>
            <tr className="text-sm dark:text-white">
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                No
              </th>
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                Harga
              </th>
              <th className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {hargas.map((harga, index) => (
              <tr key={harga.id} className="text-sm dark:text-white">
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  {index + 1}
                </td>
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  Rp. {harga.harga.toLocaleString()}
                </td>
                <td className="px-4 py-2 border-b dark:border-[#3f3f3f] whitespace-nowrap">
                  <div className="flex gap-x-2">
                    <ButtonAction
                      to={`/harga/poin/edit/${harga.id}`}
                      icon={<MdEditSquare />}
                      className={"bg-orange-600 hover:bg-orange-700"}
                    />

                    <ButtonAction
                      onClick={() => deleteHargaPoin(harga.id)}
                      icon={<MdDelete />}
                      className={"bg-red-600 hover:bg-red-700"}
                    />
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Layout;
