import { useState } from "react";
import {
  ArrowLeft,
  User,
  Mail,
  Phone,
  Lock,
  Gift,
  Eye,
  EyeOff,
  CheckCircle,
  AlertCircle,
} from "lucide-react";
import { useNavigate } from "react-router-dom";
import { API_URL } from "../config";
import axios from "axios";

const Register = () => {
  const [formData, setFormData] = useState({
    fullname: "",
    email: "",
    phone: "",
    password: "",
    referralCode: "",
    role_name: "user",
  });
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const navigate = useNavigate();

  const validateField = (name, value) => {
    switch (name) {
      case "fullname": {
        return !value ? "Nama lengkap wajib diisi" : "";
      }
      case "email": {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return !value
          ? "Email wajib diisi"
          : !emailRegex.test(value)
          ? "Email tidak valid"
          : "";
      }
      case "phone": {
        const phoneRegex = /^(?:\+62|0)[0-9]{9,12}$/;
        return !value
          ? "Nomor handphone wajib diisi"
          : !phoneRegex.test(value)
          ? "Format nomor handphone tidak valid"
          : "";
      }
      case "password": {
        return !value
          ? "Password wajib diisi"
          : value.length < 6
          ? "Password minimal 6 karakter"
          : "";
      }
      default:
        return "";
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));

    if (touched[name]) {
      setErrors((prev) => ({ ...prev, [name]: validateField(name, value) }));
    }
  };

  const handleBlur = (e) => {
    const { name, value } = e.target;
    setTouched((prev) => ({ ...prev, [name]: true }));
    setErrors((prev) => ({ ...prev, [name]: validateField(name, value) }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Validate all fields
    const newErrors = {};
    Object.keys(formData).forEach((key) => {
      if (key !== "referralCode" && key !== "role_name") {
        newErrors[key] = validateField(key, formData[key]);
      }
    });

    setErrors(newErrors);
    setTouched({
      fullname: true,
      email: true,
      phone: true,
      password: true,
    });

    // Check if there are any errors
    if (Object.values(newErrors).some((error) => error)) {
      return;
    }

    setIsSubmitting(true);
    setErrorMessage("");
    setSuccessMessage("");

    try {
      // Prepare data for backend
      const payload = {
        fullname: formData.fullname,
        email: formData.email,
        phone_number: formData.phone, // Map to phone_number as expected by backend
        password: formData.password,
        referralCode: formData.referralCode,
        role_name: formData.role_name,
      };

      // Remove empty referralCode
      if (!payload.referralCode) {
        delete payload.referralCode;
      }

      // Make API call
      await axios.post(`${API_URL}/auth/register`, payload, {
        headers: {
          "Content-Type": "application/json",
        },
      });

      // Handle successful response
      setSuccessMessage(
        "Registrasi berhasil! Silakan login menggunakan aplikasi Getsayor"
      );

      // Reset form
      setFormData({
        fullname: "",
        email: "",
        phone: "",
        password: "",
        referralCode: "",
        role_name: "user",
      });
      setTouched({});

      // Optional: Redirect after successful registration
      // navigate("/login");
    } catch (error) {
      // Handle different error responses
      let errorMsg = "Terjadi kesalahan saat registrasi";

      if (error.response) {
        // The request was made and the server responded with a status code
        if (error.response.data && error.response.data.message) {
          errorMsg = error.response.data.message;
        } else if (error.response.status === 400) {
          errorMsg = "Data yang dimasukkan tidak valid";
        } else if (error.response.status === 409) {
          errorMsg = "Email atau nomor telepon sudah terdaftar";
        }
      } else if (error.request) {
        // The request was made but no response was received
        errorMsg = "Tidak ada respon dari server";
      }

      setErrorMessage(errorMsg);
      console.error("Registration error:", error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const goBack = () => {
    navigate(-1);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-white to-emerald-50 flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={goBack}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-800 transition-colors mb-6 group"
          >
            <ArrowLeft
              size={18}
              className="group-hover:-translate-x-1 transition-transform"
            />
            <span className="text-sm font-medium">Kembali</span>
          </button>

          <div className="text-center">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-green-500 to-emerald-600 rounded-2xl mb-4 shadow-lg">
              <User className="text-white" size={24} />
            </div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              Daftar Akun
            </h1>
            <p className="text-gray-600 text-sm leading-relaxed">
              Silakan daftar untuk membuat akun. Setelah registrasi, Anda dapat
              melakukan login melalui aplikasi{" "}
              <span className="text-green-600 font-semibold">Getsayor</span>.
            </p>
          </div>
        </div>

        {/* Alert Messages */}
        {errorMessage && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl flex items-start gap-3">
            <AlertCircle
              className="text-red-500 mt-0.5 flex-shrink-0"
              size={18}
            />
            <p className="text-red-700 text-sm">{errorMessage}</p>
          </div>
        )}

        {successMessage && (
          <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl flex items-start gap-3">
            <CheckCircle
              className="text-green-500 mt-0.5 flex-shrink-0"
              size={18}
            />
            <p className="text-green-700 text-sm">{successMessage}</p>
          </div>
        )}

        {/* Form */}
        <div className="space-y-5">
          {/* Fullname Field */}
          <div>
            <label
              htmlFor="fullname"
              className="block text-sm font-semibold text-gray-700 mb-2"
            >
              Nama Lengkap <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                <User size={18} />
              </div>
              <input
                type="text"
                id="fullname"
                name="fullname"
                value={formData.fullname}
                onChange={handleChange}
                onBlur={handleBlur}
                className={`w-full pl-10 pr-4 py-3 border rounded-xl focus:outline-none focus:ring-2 transition-all ${
                  errors.fullname && touched.fullname
                    ? "border-red-300 focus:ring-red-500/20 focus:border-red-500"
                    : "border-gray-300 focus:ring-green-500/20 focus:border-green-500"
                }`}
                placeholder="Masukkan nama lengkap Anda"
              />
            </div>
            {errors.fullname && touched.fullname && (
              <p className="text-red-500 text-xs mt-1 ml-1">
                {errors.fullname}
              </p>
            )}
          </div>

          {/* Email Field */}
          <div>
            <label
              htmlFor="email"
              className="block text-sm font-semibold text-gray-700 mb-2"
            >
              Email <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                <Mail size={18} />
              </div>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                onBlur={handleBlur}
                className={`w-full pl-10 pr-4 py-3 border rounded-xl focus:outline-none focus:ring-2 transition-all ${
                  errors.email && touched.email
                    ? "border-red-300 focus:ring-red-500/20 focus:border-red-500"
                    : "border-gray-300 focus:ring-green-500/20 focus:border-green-500"
                }`}
                placeholder="contoh@email.com"
              />
            </div>
            {errors.email && touched.email && (
              <p className="text-red-500 text-xs mt-1 ml-1">{errors.email}</p>
            )}
          </div>

          {/* Phone Field */}
          <div>
            <label
              htmlFor="phone"
              className="block text-sm font-semibold text-gray-700 mb-2"
            >
              No Handphone <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                <Phone size={18} />
              </div>
              <input
                type="tel"
                id="phone"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                onBlur={handleBlur}
                className={`w-full pl-10 pr-4 py-3 border rounded-xl focus:outline-none focus:ring-2 transition-all ${
                  errors.phone && touched.phone
                    ? "border-red-300 focus:ring-red-500/20 focus:border-red-500"
                    : "border-gray-300 focus:ring-green-500/20 focus:border-green-500"
                }`}
                placeholder="081234567890"
              />
            </div>
            {errors.phone && touched.phone && (
              <p className="text-red-500 text-xs mt-1 ml-1">{errors.phone}</p>
            )}
          </div>

          {/* Password Field */}
          <div>
            <label
              htmlFor="password"
              className="block text-sm font-semibold text-gray-700 mb-2"
            >
              Password <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                <Lock size={18} />
              </div>
              <input
                type={showPassword ? "text" : "password"}
                id="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                onBlur={handleBlur}
                className={`w-full pl-10 pr-12 py-3 border rounded-xl focus:outline-none focus:ring-2 transition-all ${
                  errors.password && touched.password
                    ? "border-red-300 focus:ring-red-500/20 focus:border-red-500"
                    : "border-gray-300 focus:ring-green-500/20 focus:border-green-500"
                }`}
                placeholder="Minimal 6 karakter"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
            {errors.password && touched.password && (
              <p className="text-red-500 text-xs mt-1 ml-1">
                {errors.password}
              </p>
            )}
          </div>

          {/* Referral Code Field */}
          <div>
            <label
              htmlFor="referralCode"
              className="block text-sm font-semibold text-gray-700 mb-2"
            >
              Kode Referral{" "}
              <span className="text-gray-400 text-xs">(Opsional)</span>
            </label>
            <div className="relative">
              <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                <Gift size={18} />
              </div>
              <input
                type="text"
                id="referralCode"
                name="referralCode"
                value={formData.referralCode}
                onChange={handleChange}
                onBlur={handleBlur}
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500/20 focus:border-green-500 transition-all"
                placeholder="Masukkan kode referral (jika ada)"
              />
            </div>
          </div>

          {/* Submit Button */}
          <div
            onClick={handleSubmit}
            className="w-full bg-gradient-to-r from-green-500 to-emerald-600 text-white font-semibold py-3 px-6 rounded-xl hover:from-green-600 hover:to-emerald-700 focus:outline-none focus:ring-2 focus:ring-green-500/20 disabled:opacity-50 disabled:cursor-not-allowed transition-all transform hover:scale-[1.02] active:scale-[0.98] shadow-lg cursor-pointer text-center"
          >
            {isSubmitting ? (
              <div className="flex items-center justify-center gap-2">
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                <span>Memproses...</span>
              </div>
            ) : (
              "Daftar Sekarang"
            )}
          </div>
        </div>

        {/* Footer */}
        {/* <div className="mt-8 text-center">
          <p className="text-sm text-gray-500">
            Sudah punya akun?{" "}
            <button className="text-green-600 hover:text-green-700 font-semibold transition-colors">
              Masuk di sini
            </button>
          </p>
        </div> */}
      </div>
    </div>
  );
};

export default Register;
