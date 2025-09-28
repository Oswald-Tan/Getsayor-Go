import { useState } from "react";
import { Formik } from "formik";
import { API_URL } from "../../config";
import { Link, useNavigate } from "react-router-dom";
import { TbPasswordUser } from "react-icons/tb";
import { HiOutlineMail, HiEye, HiEyeOff } from "react-icons/hi";
import VerifyOtpForm from "./VerifyOtpForm";
import axios from "axios";
import Swal from "sweetalert2";
import * as Yup from "yup";

const ResetPasswordPage = () => {
  const [step, setStep] = useState("requestEmail");
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const navigate = useNavigate();

  const handleEmailSubmitted = async (values) => {
    setLoading(true);
    try {
      await axios.post(`${API_URL}/auth-web/request-reset-otp`, {
        email: values.email,
      });
      setEmail(values.email);
      setStep("verifyOtp");
    } catch (error) {
      Swal.fire({
        title: "Error",
        text: error.response?.data?.message || "Failed to send OTP",
        icon: "error",
        confirmButtonText: "Ok",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleOtpVerified = () => {
    setStep("resetPassword");
  };

  const handlePasswordReset = async (values) => {
    setLoading(true);
    try {
      await axios.post(`${API_URL}/auth-web/reset-password`, { ...values, email });
      Swal.fire({
        title: "Success",
        text: "Password has been reset successfully",
        icon: "success",
        confirmButtonText: "Ok",
      });
      navigate("/");
    } catch (error) {
      Swal.fire({
        title: "Error",
        text: error.response?.data?.message || "Failed to reset password",
        icon: "error",
        confirmButtonText: "Ok",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Header Section */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-[#f2fce2] to-[#d8faa5] rounded-xl mb-4 shadow-lg">
            <TbPasswordUser className="text-[#74B11A] text-2xl" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            {step === "requestEmail" ? "Request OTP" : 
             step === "verifyOtp" ? "Verify OTP" : "Reset Password"}
          </h1>
          <p className="text-gray-600">
            {step === "requestEmail" 
              ? "Enter your registered email to receive OTP" 
              : step === "verifyOtp" 
                ? "Enter the OTP sent to your email" 
                : "Set your new password"}
          </p>
        </div>

        {/* Form Container */}
        <div className="bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
          {step === "requestEmail" && (
            <Formik
              initialValues={{ email: "" }}
              onSubmit={handleEmailSubmitted}
              validationSchema={Yup.object({
                email: Yup.string()
                  .required("Email is required")
                  .email("Invalid email address"),
              })}
            >
              {({ errors, touched, handleSubmit, handleChange }) => (
                <form onSubmit={handleSubmit} className="space-y-6">
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
                        name="email"
                        onChange={handleChange}
                        placeholder="Enter your email"
                        className="w-full px-4 py-3 pl-12 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#bce25c] focus:border-transparent transition-all duration-200 bg-gray-50 hover:bg-white"
                      />
                      <HiOutlineMail className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 text-lg" />
                    </div>
                    {touched.email && errors.email && (
                      <div className="text-red-600 text-sm mt-1 italic">
                        {errors.email}
                      </div>
                    )}
                  </div>

                  {/* Submit Button */}
                  <button
                    type="submit"
                    disabled={loading}
                    className="w-full bg-gradient-to-r from-[#ABCF51] to-[#74B11A] text-white py-3 px-4 rounded-lg font-semibold text-sm hover:from-[#bce25c] hover:to-[#8bc13b] focus:outline-none focus:ring-2 focus:ring-[#bce25c] focus:ring-offset-2 transition-all duration-200 flex items-center justify-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
                  >
                    {loading ? (
                      <div className="flex items-center gap-2">
                        <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        Sending OTP...
                      </div>
                    ) : (
                      "Request OTP"
                    )}
                  </button>
                </form>
              )}
            </Formik>
          )}

          {step === "verifyOtp" && (
            <VerifyOtpForm email={email} onVerified={handleOtpVerified} />
          )}

          {step === "resetPassword" && (
            <Formik
              initialValues={{
                newPassword: "",
                confirmPassword: "",
              }}
              onSubmit={handlePasswordReset}
              validationSchema={Yup.object({
                newPassword: Yup.string()
                  .required("New password is required")
                  .min(8, "Password must be at least 8 characters")
                  .matches(/[a-zA-Z]/, "Password must contain letters")
                  .matches(/[0-9]/, "Password must contain numbers")
                  .matches(/[\W_]/, "Password must contain special characters"),
                confirmPassword: Yup.string()
                  .required("Confirm password is required")
                  .oneOf([Yup.ref("newPassword"), null], "Passwords must match"),
              })}
            >
              {({ errors, touched, handleSubmit, handleChange }) => (
                <form onSubmit={handleSubmit} className="space-y-6">
                  {/* New Password Field */}
                  <div className="space-y-2">
                    <label
                      htmlFor="newPassword"
                      className="text-sm font-medium text-gray-700 block"
                    >
                      New Password
                    </label>
                    <div className="relative">
                      <input
                        type={showPassword ? "text" : "password"}
                        id="newPassword"
                        name="newPassword"
                        onChange={handleChange}
                        placeholder="Enter new password"
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
                    {touched.newPassword && errors.newPassword && (
                      <div className="text-red-600 text-sm mt-1 italic">
                        {errors.newPassword}
                      </div>
                    )}
                  </div>

                  {/* Confirm Password Field */}
                  <div className="space-y-2">
                    <label
                      htmlFor="confirmPassword"
                      className="text-sm font-medium text-gray-700 block"
                    >
                      Confirm Password
                    </label>
                    <div className="relative">
                      <input
                        type={showConfirmPassword ? "text" : "password"}
                        id="confirmPassword"
                        name="confirmPassword"
                        onChange={handleChange}
                        placeholder="Confirm new password"
                        className="w-full px-4 py-3 pr-12 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#bce25c] focus:border-transparent transition-all duration-200 bg-gray-50 hover:bg-white"
                      />
                      <button
                        type="button"
                        onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                        className="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
                      >
                        {showConfirmPassword ? (
                          <HiEyeOff className="text-lg" />
                        ) : (
                          <HiEye className="text-lg" />
                        )}
                      </button>
                    </div>
                    {touched.confirmPassword && errors.confirmPassword && (
                      <div className="text-red-600 text-sm mt-1 italic">
                        {errors.confirmPassword}
                      </div>
                    )}
                  </div>

                  {/* Submit Button */}
                  <button
                    type="submit"
                    disabled={loading}
                    className="w-full bg-gradient-to-r from-[#ABCF51] to-[#74B11A] text-white py-3 px-4 rounded-lg font-semibold text-sm hover:from-[#bce25c] hover:to-[#8bc13b] focus:outline-none focus:ring-2 focus:ring-[#bce25c] focus:ring-offset-2 transition-all duration-200 flex items-center justify-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed shadow-lg hover:shadow-xl"
                  >
                    {loading ? (
                      <div className="flex items-center gap-2">
                        <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        Resetting Password...
                      </div>
                    ) : (
                      "Reset Password"
                    )}
                  </button>
                </form>
              )}
            </Formik>
          )}

          {/* Footer */}
          <div className="mt-6 pt-6 border-t border-gray-200">
            <Link
              to="/"
              className="text-sm text-[#74B11A] hover:text-[#ABCF51] font-medium transition-colors text-center block"
            >
              Back to login
            </Link>
          </div>
        </div>

        {/* Additional Info */}
        <div className="text-center mt-6">
          <p className="text-xs text-gray-500">
            Secure password reset process
          </p>
        </div>
      </div>
    </div>
  );
};

export default ResetPasswordPage;