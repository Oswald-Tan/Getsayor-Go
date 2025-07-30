import { useEffect, useState } from "react";
import axios from "axios";
import { API_URL } from "../config";
import { useParams } from "react-router-dom";

const UserDetails = () => {
  const { id } = useParams();
  const [userDetails, setUserDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [profileStatus, setProfileStatus] = useState("Incomplete");

  useEffect(() => {
    const getUsers = async () => {
      try {
        const res = await axios.get(`${API_URL}/users/${id}/details`);
        if (!res.data) {
          setError("Belum ada detail");
        } else {
          setUserDetails(res.data);
          console.log(res.data);
          // Check profile completeness
          const requiredFields = [
            "fullname",
            "email",
            "phone_number",
            "photo_profile",
          ];
          const isComplete = requiredFields.every(
            (field) =>
              res.data[field] !== null &&
              res.data[field] !== undefined &&
              res.data[field] !== ""
          );

          setProfileStatus(isComplete ? "Complete" : "Incomplete");
        }
      } catch (error) {
        if (error.response && error.response.status === 404) {
          setError("Detail User Belum Ada");
        } else {
          setError(error.message);
        }
      } finally {
        setLoading(false);
      }
    };
    getUsers();
  }, [id]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="flex items-center space-x-2">
          <div className="w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          <span className="text-gray-600 dark:text-gray-400">
            Loading user details...
          </span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="text-center">
          <div className="flex items-center justify-center w-16 h-16 bg-red-100 dark:bg-red-900/20 rounded-full mx-auto mb-4">
            <svg
              className="w-8 h-8 text-red-500 dark:text-red-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <h3 className="text-lg font-semibold text-red-700 dark:text-red-400 mb-2">
            Error
          </h3>
          <p className="text-red-600 dark:text-red-400">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-8 px-4 sm:px-6 lg:px-8 rounded-2xl">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            User Details
          </h1>
          <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
            Complete information about the user
          </p>
        </div>

        {/* User Profile Card */}
        <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl border border-gray-200 dark:border-gray-700 overflow-hidden">
          {/* Card Header */}
          <div className="bg-gradient-to-r from-blue-500 to-purple-600 px-8 py-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                {userDetails?.photo_profile ? (
                  <img
                    src={userDetails.photo_profile}
                    alt={userDetails.fullname || "User"}
                    className="w-20 h-20 rounded-full border-4 border-white/30 object-cover"
                  />
                ) : (
                  <div className="w-20 h-20 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center border-4 border-white/30">
                    <svg
                      className="w-10 h-10 text-white"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                      />
                    </svg>
                  </div>
                )}
              </div>
              <div className="ml-6">
                <h2 className="text-2xl font-bold text-white">
                  {userDetails?.fullname || "User"}
                </h2>
                <p className="text-blue-100 text-sm mt-1">User ID: {id}</p>
              </div>
            </div>
          </div>

          {/* User Information */}
          <div className="px-8 py-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Full Name */}
              <div className="bg-gray-50 dark:bg-gray-700 rounded-xl p-6">
                <div className="flex items-center mb-3">
                  <div className="flex items-center justify-center w-10 h-10 bg-blue-100 dark:bg-blue-800 rounded-lg mr-3">
                    <svg
                      className="w-5 h-5 text-blue-600 dark:text-blue-400"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                      />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-500 dark:text-gray-400">
                      Full Name
                    </p>
                    <p className="text-lg font-semibold text-gray-900 dark:text-white">
                      {userDetails?.fullname || "Not provided"}
                    </p>
                  </div>
                </div>
              </div>

              {/* Email */}
              <div className="bg-gray-50 dark:bg-gray-700 rounded-xl p-6">
                <div className="flex items-center mb-3">
                  <div className="flex items-center justify-center w-10 h-10 bg-green-100 dark:bg-green-800 rounded-lg mr-3">
                    <svg
                      className="w-5 h-5 text-green-600 dark:text-green-400"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"
                      />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-500 dark:text-gray-400">
                      Email Address
                    </p>
                    <p className="text-lg font-semibold text-gray-900 dark:text-white">
                      {userDetails?.email || "Not provided"}
                    </p>
                  </div>
                </div>
              </div>

              {/* Phone Number */}
              <div className="bg-gray-50 dark:bg-gray-700 rounded-xl p-6">
                <div className="flex items-center mb-3">
                  <div className="flex items-center justify-center w-10 h-10 bg-purple-100 dark:bg-purple-800 rounded-lg mr-3">
                    <svg
                      className="w-5 h-5 text-purple-600 dark:text-purple-400"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
                      />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-500 dark:text-gray-400">
                      Phone Number
                    </p>
                    <p className="text-lg font-semibold text-gray-900 dark:text-white">
                      {userDetails?.phone_number || "Not provided"}
                    </p>
                  </div>
                </div>
              </div>

              {/* Profile Image */}
              <div className="bg-gray-50 dark:bg-gray-700 rounded-xl p-6">
                <div className="flex items-center mb-3">
                  <div className="flex items-center justify-center w-10 h-10 bg-orange-100 dark:bg-orange-800 rounded-lg mr-3">
                    <svg
                      className="w-5 h-5 text-orange-600 dark:text-orange-400"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                      />
                    </svg>
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-gray-500 dark:text-gray-400">
                      Profile Image
                    </p>
                    {userDetails?.photo_profile ? (
                      <div className="flex items-center mt-2">
                        <img
                          src={userDetails.photo_profile}
                          alt="Profile"
                          className="w-12 h-12 rounded-lg object-cover border-2 border-gray-200 dark:border-gray-600"
                        />
                        <div className="ml-3">
                          <p className="text-sm font-medium text-green-600 dark:text-green-400">
                            Image available
                          </p>
                          <a
                            href={userDetails.photo_profile}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-xs text-blue-600 dark:text-blue-400 hover:underline"
                          >
                            View full image
                          </a>
                        </div>
                      </div>
                    ) : (
                      <p className="text-lg font-semibold text-gray-900 dark:text-white">
                        Not provided
                      </p>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {/* Additional Info */}
            <div className="mt-8 bg-blue-50 dark:bg-blue-900/20 rounded-xl p-6">
              <div className="flex items-center mb-3">
                <div className="flex items-center justify-center w-8 h-8 bg-blue-100 dark:bg-blue-800 rounded-lg mr-3">
                  <svg
                    className="w-4 h-4 text-blue-600 dark:text-blue-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-100">
                  Account Information
                </h3>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                <div>
                  <span className="font-medium text-blue-700 dark:text-blue-300">
                    User ID:
                  </span>
                  <span className="ml-2 text-blue-600 dark:text-blue-400">
                    {id}
                  </span>
                </div>
                <div>
                  <span className="font-medium text-blue-700 dark:text-blue-300">
                    Profile Status:
                  </span>
                  <span
                    className={`ml-2 font-semibold ${
                      profileStatus === "Complete"
                        ? "text-green-600 dark:text-green-400"
                        : "text-yellow-600 dark:text-yellow-400"
                    }`}
                  >
                    {profileStatus}
                    {profileStatus === "Incomplete" && (
                      <span className="block text-xs text-yellow-700 dark:text-yellow-300 mt-1">
                        (Missing some information)
                      </span>
                    )}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UserDetails;
