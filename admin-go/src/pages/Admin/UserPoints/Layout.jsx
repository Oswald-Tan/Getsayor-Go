import { useEffect, useState } from "react";
import axios from "axios";
import { API_URL } from "../../../config";
import { useParams } from 'react-router-dom';
import ModalPoint from "../../../components/ui/ModalPoint";
import Swal from "sweetalert2";

const Layout = () => {
  const { id } = useParams();
  const [userPoints, setUserPoints] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newPoints, setNewPoints] = useState("");
  const [updateError, setUpdateError] = useState(null);
  const [isUpdating, setIsUpdating] = useState(false);

  const formatRibuan = (angka) => {
    if (!angka) return "0";
    return angka.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
  };

  useEffect(() => {
    const getUsers = async () => {
      try {
        const res = await axios.get(`${API_URL}/users/${id}/points`);
        setUserPoints(res.data);
      } catch (error) {
        setError(error.message); 
      } finally {
        setLoading(false);
      }
    };
    getUsers();
  }, [id]);

  const handleOpenModal = () => {
    setNewPoints(userPoints.points?.toString() || "0");
    setIsModalOpen(true);
    setUpdateError(null);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsUpdating(true);
    setUpdateError(null);
    
    try {
      // Konversi ke angka (hilangkan titik jika ada)
      const pointsValue = parseInt(newPoints.replace(/\./g, ''));
      
      if (isNaN(pointsValue)) {
        throw new Error("Invalid points value");
      }

      // Kirim permintaan update
      const response = await axios.put(`${API_URL}/users/${id}/points`, {
        points: pointsValue
      });

      // Update state dengan nilai baru
      setUserPoints(prev => ({
        ...prev,
        points: response.data.data.points
      }));

      Swal.fire({
        title: "Success!",
        text: "Points updated successfully",
        icon: "success",
        confirmButtonColor: "#3085d6",
        confirmButtonText: "OK"
      });

      setIsModalOpen(false);
    } catch (error) {
       const errorMessage = error.response?.data?.message || error.message;
      setUpdateError(error.response?.data?.message || error.message);

       // Tampilkan swal error
      Swal.fire({
        title: "Error!",
        text: errorMessage,
        icon: "error",
        confirmButtonColor: "#d33",
        confirmButtonText: "OK"
      });
    } finally {
      setIsUpdating(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="flex items-center space-x-2">
          <div className="w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          <span className="text-gray-600 dark:text-gray-400">Loading...</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-700 dark:text-red-400 px-4 py-3 rounded-lg">
          <p className="font-medium">Error: {error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
                User Points Management
              </h1>
              <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
                Manage and track user reward points
              </p>
            </div>
            <div className="mt-4 sm:mt-0">
              <button
                onClick={handleOpenModal}
                className="inline-flex items-center px-6 py-3 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200 transform hover:scale-105"
              >
                <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                Edit Points
              </button>
            </div>
          </div>
        </div>

        {/* User Info Card */}
        <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-700 overflow-hidden">
          {/* Card Header */}
          <div className="bg-gradient-to-r from-blue-500 to-purple-600 p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center">
                  <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>
              </div>
              <div className="ml-6">
                <h2 className="text-2xl font-bold text-white">
                  {userPoints?.fullname || "User"}
                </h2>
                <p className="text-blue-100 text-sm">
                  {userPoints?.email || "No email available"}
                </p>
                <p className="text-blue-100 text-xs mt-1">
                  ID: {userPoints?.id || id}
                </p>
              </div>
            </div>
          </div>

          {/* Points Display */}
          <div className="px-8 py-10">
            <div className="text-center">
              <div className="mb-4">
                <div className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-r from-yellow-400 to-orange-500 rounded-full shadow-lg">
                  <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                  </svg>
                </div>
              </div>
              
              <div className="mb-2">
                <span className="text-sm font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">
                  Current Points
                </span>
              </div>
              
              <div className="mb-6">
                <span className="text-5xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                  {formatRibuan(userPoints?.points) || "0"}
                </span>
                <span className="text-xl text-gray-500 dark:text-gray-400 ml-2">pts</span>
              </div>


            </div>
          </div>
        </div>

      
      </div>

      {/* Modal Edit Points */}
      <ModalPoint isOpen={isModalOpen} onClose={handleCloseModal}>
        <div className="bg-white dark:bg-gray-800 p-8 rounded-2xl w-[700px] max-w-md shadow-2xl border border-gray-200 dark:border-gray-700">
          <div className="text-center mb-6">
            <div className="flex items-center justify-center w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full mx-auto mb-4">
              <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
            </div>
            <h3 className="text-2xl font-bold text-gray-900 dark:text-white">Edit User Points</h3>
            <p className="text-gray-500 dark:text-gray-400 mt-2">
              Update points for {userPoints?.fullname}
            </p>
          </div>
          
          {updateError && (
            <div className="mb-6 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-700 dark:text-red-400 rounded-lg">
              <div className="flex items-center">
                <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                {updateError}
              </div>
            </div>
          )}
          
          <form onSubmit={handleSubmit}>
            <div className="mb-6">
              <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3">
                Points Amount
              </label>
              <div className="relative">
                <input
                  type="text"
                  className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 group-hover:shadow-md dark:bg-gray-700 dark:text-white text-lg font-medium"
                  value={newPoints}
                  onChange={(e) => {
                    // Hanya izinkan angka dan titik
                    const value = e.target.value.replace(/[^\d.]/g, '');
                    setNewPoints(value);
                  }}
                  placeholder="Enter points amount"
                />
                <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <span className="text-gray-500 dark:text-gray-400 text-sm">pts</span>
                </div>
              </div>
            </div>
            
            <div className="flex space-x-4">
              <button
                type="button"
                className="flex-1 px-6 py-3 text-base font-medium text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-500 transition-all duration-200"
                onClick={handleCloseModal}
                disabled={isUpdating}
              >
                Cancel
              </button>
              <button
                type="submit"
                className="flex-1 px-6 py-3 text-base font-medium text-white bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg hover:from-blue-600 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                disabled={isUpdating}
              >
                {isUpdating ? (
                  <div className="flex items-center justify-center">
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                    Saving...
                  </div>
                ) : (
                  "Save Changes"
                )}
              </button>
            </div>
          </form>
        </div>
      </ModalPoint>
    </div>
  );
};

export default Layout;