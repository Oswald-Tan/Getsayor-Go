import { useState, useCallback } from "react";
import { User, Mail, Lock, Shield, Eye, EyeOff } from "lucide-react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import Swal from "sweetalert2";
import { API_URL } from "../../../config";
import PropTypes from "prop-types";
import { HiOutlineUserPlus } from "react-icons/hi2";

// Reusable InputField component
const InputField = ({
  label,
  type = "text",
  value,
  onChange,
  placeholder,
  icon: Icon,
  showPasswordToggle = false,
  showPassword = false,
  onTogglePassword,
}) => (
  <div className="space-y-2">
    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
      {label}
    </label>
    <div className="relative">
      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
        <Icon className="h-4 w-4 text-gray-400" />
      </div>
      <input
        type={showPasswordToggle ? (showPassword ? "text" : "password") : type}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        className="w-full pl-10 pr-12 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 text-sm"
      />
      {showPasswordToggle && (
        <button
          type="button"
          onClick={onTogglePassword}
          className="absolute inset-y-0 right-0 pr-3 flex items-center"
        >
          {showPassword ? (
            <EyeOff className="h-4 w-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" />
          ) : (
            <Eye className="h-4 w-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" />
          )}
        </button>
      )}
    </div>
  </div>
);

const Layout = () => {
  const [fullname, setFullname] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [role, setRole] = useState("");
  const [msg, setMsg] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const navigate = useNavigate();

  // Password toggle handlers
  const togglePassword = useCallback(
    () => setShowPassword((prev) => !prev),
    []
  );
  const toggleConfirmPassword = useCallback(
    () => setShowConfirmPassword((prev) => !prev),
    []
  );

  const saveUser = async (e) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      await axios.post(`${API_URL}/users`, {
        fullname,
        email,
        password,
        confirmPassword,
        roleName: role,
      });
      navigate("/users");
      Swal.fire("Success", "User added successfully", "success");
    } catch (error) {
      if (error.response) {
        setMsg(error.response.data.message);
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      <div className="space-y-6 w-full">
        {/* Header Section */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl">
              <HiOutlineUserPlus className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                Add New User
              </h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Create a new user account with specific role permissions
              </p>
            </div>
          </div>
        </div>

        {/* Form Card */}
        <div className="bg-white dark:bg-[#282828] rounded-2xl shadow-xl border border-gray-200 dark:border-[#575757] overflow-hidden">
          <div className="p-8">
            <form onSubmit={saveUser} className="space-y-6">
              {/* Error Message */}
              {msg && (
                <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4">
                  <p className="text-red-700 dark:text-red-400 text-sm font-medium">
                    {msg}
                  </p>
                </div>
              )}

              {/* Form Fields */}
              <div className="grid gap-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <InputField
                    key="fullname-field"
                    label="Full Name"
                    value={fullname}
                    onChange={(e) => setFullname(e.target.value)}
                    placeholder="Enter full name"
                    icon={User}
                  />

                  <InputField
                    key="email-field"
                    label="Email Address"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Enter email address"
                    icon={Mail}
                  />

                  <InputField
                    key="password-field"
                    label="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Enter password"
                    icon={Lock}
                    showPasswordToggle={true}
                    showPassword={showPassword}
                    onTogglePassword={togglePassword}
                  />

                  <InputField
                    key="confirm-password-field"
                    label="Confirm Password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="Confirm password"
                    icon={Lock}
                    showPasswordToggle={true}
                    showPassword={showConfirmPassword}
                    onTogglePassword={toggleConfirmPassword}
                  />
                </div>

                {/* Role Select */}
                <div className="space-y-2">
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                    Role
                  </label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Shield className="h-4 w-4 text-gray-400" />
                    </div>
                    <select
                      value={role}
                      onChange={(e) => setRole(e.target.value)}
                      className="w-full pl-10 pr-4 py-3 border border-gray-300 dark:border-[#575757] rounded-xl shadow-sm bg-white dark:bg-[#3f3f3f] text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-500 appearance-none cursor-pointer text-sm"
                      required
                    >
                      <option value="">Pilih role...</option>
                      <option value="admin">Admin</option>
                      <option value="user">User</option>
                      <option value="kurir">Kurir</option>
                    </select>
                    <div className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                      <svg
                        className="h-5 w-5 text-gray-400"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                      >
                        <path
                          fillRule="evenodd"
                          d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                          clipRule="evenodd"
                        />
                      </svg>
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="pt-6 border-t border-gray-200 dark:border-[#575757]">
                <button
                  type="submit"
                  disabled={isLoading}
                  className="flex-1 px-6 py-3 text-sm bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-medium rounded-xl shadow-lg hover:shadow-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  {isLoading ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                      Creating User...
                    </>
                  ) : (
                    "Create User"
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>

        {/* Additional Info */}
        <div className="mt-6 text-center">
          <p className="text-sm text-gray-500 dark:text-gray-400">
            Passwords must be at least 8 characters long and include both letters and numbers
          </p>
        </div>
      </div>
    </div>
  );
};

InputField.propTypes = {
  label: PropTypes.string.isRequired,
  type: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onChange: PropTypes.func.isRequired,
  placeholder: PropTypes.string,
  icon: PropTypes.elementType.isRequired,
  showPasswordToggle: PropTypes.bool,
  showPassword: PropTypes.bool,
  onTogglePassword: PropTypes.func,
};

export default Layout;