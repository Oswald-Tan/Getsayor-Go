import { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, useNavigate } from "react-router-dom";
import { LoginUser, reset } from "../../features/authSlice";
import { FaLongArrowAltRight, FaShoppingCart } from "react-icons/fa";
import { HiEye, HiEyeOff } from "react-icons/hi";
import { HiMiniUser } from "react-icons/hi2";
import { getDashboardPathByRole } from "../../utils/roleRoutes";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { user, isSuccess, isLoading, isError, message } = useSelector(
    (state) => state.auth
  );

   useEffect(() => {
    if (user || isSuccess) {
     const path = getDashboardPathByRole(user?.role);
     navigate(path);
    }

    return () => {
      dispatch(reset());
    };
  }, [user, isSuccess, dispatch, navigate]);

  const Auth = async (e) => {
    e.preventDefault();
    dispatch(LoginUser({ email, password }));
  };

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Header Section */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-[#ABCF51] to-[#74B11A] rounded-xl mb-4 shadow-lg">
            <FaShoppingCart className="text-white text-2xl" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Admin Portal
          </h1>
          <p className="text-gray-600">Sign in to your Getsayor dashboard</p>
        </div>

        {/* Login Form */}
        <div className="bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
          <form onSubmit={Auth} className="space-y-6">
            {/* Email Field */}
            <div className="space-y-2">
              <label
                htmlFor="email"
                className="text-sm font-medium text-gray-700 block"
              >
                Email Address
              </label>
              <div className="relative">
                <input
                  type="email"
                  id="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  placeholder="Enter your email"
                  className="w-full px-4 py-3 pl-12 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#bce25c] focus:border-transparent transition-all duration-200 bg-gray-50 hover:bg-white"
                />
                <HiMiniUser className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 text-lg" />
              </div>
            </div>

            {/* Password Field */}
            <div className="space-y-2">
              <label
                htmlFor="password"
                className="text-sm font-medium text-gray-700 block"
              >
                Password
              </label>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  id="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  placeholder="Enter your password"
                  className="w-full px-4 py-3 pr-12 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#bce25c] focus:border-transparent transition-all duration-200 bg-gray-50 hover:bg-white"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
                >
                  {showPassword ? (
                    <HiEyeOff className="text-lg" />
                  ) : (
                    <HiEye className="text-lg" />
                  )}
                </button>
              </div>
            </div>

            {/* Tampilkan pesan error */}
            {isError && (
              <div className="p-3 bg-red-50 border border-red-200 text-red-600 rounded-lg">
                {message || "Login failed. Please check your credentials"}
              </div>
            )}

            {/* Forgot Password Link */}
            <div className="flex justify-end">
              <Link
                to="/forgot/password"
                className="text-sm text-[#74B11A] hover:text-[#ABCF51] font-medium transition-colors"
              >
                Forgot your password?
              </Link>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-gradient-to-r from-[#ABCF51] to-[#74B11A] text-white py-3 px-4 rounded-lg font-semibold text-sm hover:from-[#bce25c] hover:to-[#8bc13b] focus:outline-none focus:ring-2 focus:ring-[#bce25c] focus:ring-offset-2 transition-all duration-200 flex items-center justify-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
            >
              {isLoading ? (
                <div className="flex items-center gap-2">
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  Signing in...
                </div>
              ) : (
                <>
                  Sign In
                  <FaLongArrowAltRight className="text-lg" />
                </>
              )}
            </button>
          </form>

          {/* Footer */}
          <div className="mt-6 pt-6 border-t border-gray-200">
            <p className="text-center text-sm text-gray-600">
              Secure admin access for authorized personnel only
            </p>
          </div>
        </div>

        {/* Additional Info */}
        <div className="text-center mt-6">
          <p className="text-xs text-gray-500">
            Protected by enterprise-grade security
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
