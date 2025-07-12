import { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, useNavigate } from "react-router-dom";
import { LoginUser, reset } from "../../features/authSlice";
import { FaLongArrowAltRight } from "react-icons/fa";
import { HiEye, HiEyeOff } from "react-icons/hi";
import { HiMiniUser } from "react-icons/hi2";
import LoginLogo from "../../assets/login_logo.png";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { user, isSuccess, isLoading } = useSelector(
    (state) => state.auth
  );

  // Cek apakah sudah login, jika ya arahkan ke dashboard
  useEffect(() => {
    if (user || isSuccess) {
      navigate("/dashboard");
    }
    // Reset state hanya ketika pengguna logout
    return () => {
      dispatch(reset());
    };
  }, [user, isSuccess, dispatch, navigate]);

  const Auth = async (e) => {
    e.preventDefault();
    dispatch(LoginUser({ email, password }));
  };

  return (
    <div className="flex justify-center items-center min-h-screen bg-white p-5">
      <div className="rounded-lg w-full max-w-sm">
        <img src={LoginLogo} alt="logo" className="mx-auto w-[85px] mb-5" />
        <h2 className="text-3xl font-bold text-center">Welcome back!</h2>
        <p className="text-sm text-gray-500 mb-8 mt-1 text-center">
          Please login to your account
        </p>
        <form onSubmit={Auth} className="space-y-4">
          <div className="relative">
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="Email"
              className="w-full text-sm px-4 py-3 border rounded-md focus:outline-none bg-[#eef0f4]"
            />
            <span className="text-gray-500 absolute top-[15px] right-[17px]">
              <HiMiniUser />
            </span>
          </div>
          <div className="relative">
            <input
              type={showPassword ? "text" : "password"}
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder="password"
              className="appearance-none w-full text-sm px-4 py-3 border rounded-md focus:outline-none bg-[#eef0f4]"
            />
            <span
              className="text-gray-500 absolute top-[15px] right-[17px]"
              onClick={() => setShowPassword(!showPassword)}
            >
              {showPassword ? <HiEyeOff /> : <HiEye />}
            </span>
          </div>
          <Link to="/forgot/password" className="flex justify-end">
            <p className="text-sm text-gray-500 underline cursor-pointer">
              Forgot Password?
            </p>
          </Link>
          <button
            type="submit"
            className="flex items-center justify-center gap-x-1 w-full py-3 bg-[#74B11A] font-semibold text-white text-sm rounded-md hover:bg-[#a1e043] transition-all duration-300 ease-in-out"
          >
            {isLoading ? "Loading..." : "Login"}{" "}
            <FaLongArrowAltRight size={18} />
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
