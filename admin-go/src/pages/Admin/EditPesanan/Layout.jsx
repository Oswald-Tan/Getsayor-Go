import { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
import { API_URL } from "../../../config";
import Swal from "sweetalert2";
import { HiOutlineClipboardList, HiOutlineRefresh } from "react-icons/hi";

const Layout = () => {
  const [currentStatus, setCurrentStatus] = useState("");
  const [selectedStatus, setSelectedStatus] = useState("");
  const [msg, setMsg] = useState("");
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const { id } = useParams();

  useEffect(() => {
    const getPesananUpById = async () => {
      try {
        setIsLoading(true);
        const res = await axios.get(`${API_URL}/pesanan/status/${id}`);
        setCurrentStatus(res.data.status);
        setSelectedStatus(res.data.status); // Initialize selected status with current status
      } catch (error) {
        if (error.response) {
          setMsg(error.response.data.message);
        }
      } finally {
        setIsLoading(false);
      }
    };

    getPesananUpById();
  }, [id]);

  const updatePesanan = async (e) => {
    e.preventDefault();
    if (selectedStatus === currentStatus) {
      Swal.fire("Info", "Status pesanan tidak berubah", "info");
      return;
    }
    
    setIsLoading(true);
    try {
      await axios.put(`${API_URL}/pesanan/${id}`, { status: selectedStatus });
      navigate("/pesanan");
      Swal.fire("Success", "Status updated successfully", "success");
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const statusOptions = [
    { value: "pending", label: "Pending", color: "bg-yellow-100 text-yellow-800" },
    { value: "confirmed", label: "Confirmed", color: "bg-blue-100 text-blue-800" },
    { value: "processed", label: "Processed", color: "bg-indigo-100 text-indigo-800" },
    { value: "out-for-delivery", label: "Out for Delivery", color: "bg-purple-100 text-purple-800" },
    { value: "delivered", label: "Delivered", color: "bg-green-100 text-green-800" },
    { value: "cancelled", label: "Cancelled", color: "bg-red-100 text-red-800" },
  ];

  return (
    <div>
      <div className="max-w-4xl mx-auto">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <HiOutlineClipboardList className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Edit Status Pesanan
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Update status pesanan #{id}
              </p>
            </div>
          </div>
          
          <button 
            onClick={() => navigate('/pesanan')}
            className="px-4 py-2 text-sm text-white bg-blue-500 dark:bg-gray-700 rounded-lg hover:bg-blue-600 transition-colors"
          >
            Kembali ke Daftar Pesanan
          </button>
        </div>

        {/* Current Status Badge */}
        {/* {currentStatus && (
          <div className="mb-6">
            <div className="inline-flex items-center px-4 py-2 bg-gray-100 dark:bg-gray-700 rounded-lg">
              <span className="font-medium text-gray-700 dark:text-gray-300 mr-2">Status Saat Ini:</span>
              {statusOptions.find(opt => opt.value === currentStatus) && (
                <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                  statusOptions.find(opt => opt.value === currentStatus).color
                }`}>
                  {statusOptions.find(opt => opt.value === currentStatus).label}
                </span>
              )}
            </div>
          </div>
        )} */}

        {/* Status Flow */}
        <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-md border border-gray-200 dark:border-gray-700 mb-6">
          <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-3">Alur Status Pesanan</h3>
          <div className="flex flex-wrap items-center justify-between gap-2">
            {statusOptions.map((option, index) => (
              <div key={option.value} className="flex items-center">
                <div className={`px-3 py-1.5 rounded-full text-xs font-medium ${
                  option.color
                } ${
                  currentStatus === option.value ? "ring-2 ring-offset-2 ring-blue-500" : ""
                }`}>
                  {option.label}
                </div>
                {index < statusOptions.length - 1 && (
                  <div className="mx-2 text-gray-400 dark:text-gray-500">
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Form Section */}
        <div className="p-6 bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-700">
          {isLoading ? (
            <div className="flex flex-col items-center justify-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
              <p className="mt-4 text-gray-600 dark:text-gray-400">Memuat data pesanan...</p>
            </div>
          ) : (
            <form onSubmit={updatePesanan}>
              {msg && (
                <div className="mb-6 p-4 bg-red-50 dark:bg-red-900/30 text-red-700 dark:text-red-300 rounded-lg">
                  {msg}
                </div>
              )}
              
              <div className="mb-8">
                <h3 className="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-4">
                  Pilih Status Baru
                </h3>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {statusOptions.map(option => (
                    <div 
                      key={option.value}
                      className={`p-4 rounded-xl border-2 cursor-pointer transition-all ${
                        selectedStatus === option.value 
                          ? "border-blue-500 bg-blue-50 dark:bg-blue-900/20 dark:border-blue-600" 
                          : "border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600"
                      } ${
                        currentStatus === option.value ? "ring-1 ring-blue-300" : ""
                      }`}
                      onClick={() => setSelectedStatus(option.value)}
                    >
                      <div className="flex items-center">
                        <div className="flex items-center h-5">
                          <input
                            type="radio"
                            id={`status-${option.value}`}
                            name="status"
                            value={option.value}
                            checked={selectedStatus === option.value}
                            onChange={() => setSelectedStatus(option.value)}
                            className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 dark:border-gray-600 dark:bg-gray-700"
                          />
                        </div>
                        <label 
                          htmlFor={`status-${option.value}`} 
                          className="ml-3 block text-sm font-medium text-gray-700 dark:text-gray-300 cursor-pointer"
                        >
                          {option.label}
                          {currentStatus === option.value && (
                            <span className="ml-2 text-xs text-blue-600 dark:text-blue-400">(Status Saat Ini)</span>
                          )}
                        </label>
                      </div>
                      
                      <div className={`mt-2 px-3 py-1 rounded-full text-xs font-medium inline-block ${option.color}`}>
                        {option.value}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              
              {/* Action Buttons */}
              <div className="pt-4 border-t border-gray-200 dark:border-gray-700">
                <button
                  type="submit"
                  disabled={isLoading || selectedStatus === currentStatus}
                  className={`flex-1 px-6 py-3 text-sm bg-gradient-to-r from-blue-600 to-blue-700 text-white font-medium rounded-xl shadow-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200 flex items-center justify-center gap-2 ${
                    isLoading ? 'opacity-70 cursor-not-allowed' : ''
                  } ${
                    selectedStatus === currentStatus ? 'from-gray-400 to-gray-500 cursor-not-allowed' : 'hover:from-blue-700 hover:to-blue-800 hover:shadow-xl'
                  }`}
                >
                  {isLoading ? (
                    <>
                      <HiOutlineRefresh className="animate-spin h-5 w-5" />
                      Memperbarui...
                    </>
                  ) : (
                    selectedStatus === currentStatus ? "Status Sudah Aktif" : "Perbarui Status"
                  )}
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};

export default Layout;