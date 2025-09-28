import PropTypes from "prop-types";
import { useState, useEffect } from "react";
import axios from "axios";
import Swal from "sweetalert2";
import { API_URL } from "../../config";
import OtpInput from "react-otp-input";

const VerifyOtpForm = ({ email, onVerified }) => {
  const [otp, setOtp] = useState("");
  const [loading, setLoading] = useState(false);
  const [expiryTime, setExpiryTime] = useState(null);
  const [timeLeft, setTimeLeft] = useState(null);

  useEffect(() => {
    const fetchOtpExpiryTime = async () => {
      try {
        const response = await axios.post(
          `${API_URL}/auth-web/get-reset-otp-expiry`,
          { email },
          {
            headers: {
              Authorization: `Bearer ${sessionStorage.getItem("token")}`,
            },
          }
        );
        setExpiryTime(new Date(response.data.expiryTime));
      } catch (error) {
        console.error("Failed to fetch OTP expiry time", error);
      }
    };

    fetchOtpExpiryTime();
  }, [email]);

  useEffect(() => {
    if (!expiryTime) return;

    const interval = setInterval(() => {
      const now = new Date();
      const timeDifference = expiryTime - now;

      if (timeDifference <= 0) {
        clearInterval(interval);
        setTimeLeft("OTP kadaluarsa");
      } else {
        const minutes = Math.floor(timeDifference / (1000 * 60));
        const seconds = Math.floor((timeDifference % (1000 * 60)) / 1000);
        setTimeLeft(`${minutes}m ${seconds}s`);
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [expiryTime]);

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await axios.post(`${API_URL}/auth-web/verify-reset-otp`, { email, otp });
      onVerified();
    } catch (err) {
      Swal.fire({
        title: "Failed",
        text: err.response.data.message,
        icon: "error",
        confirmButtonText: "Ok",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleVerifyOtp}>
      <p className="mt-[10px] text-3xl font-bold text-center">Kode OTP</p>
      <div className="mt-5">
        <OtpInput
          value={otp}
          onChange={setOtp}
          numInputs={6}
          separator={<span>-</span>}
          containerStyle={{
            display: "flex",
            justifyContent: "center",
            columnGap: "10px",
          }}
          inputStyle={{
            width: "100%",
            textAlign: "center",
            fontSize: "1rem",
            borderRadius: "4px",
          }}
          renderInput={(props) => (
            <input
              {...props}
              className="w-12 h-12 text-center text-lg border border-gray-300 rounded-[4px] outline-none transition-all bg-[#eef0f4]"
            />
          )}
        />

        <div className="text-sm text-[#909090] text-center mt-4">
          {timeLeft ? `Waktu tersisa: ${timeLeft}` : "Menunggu OTP..."}
        </div>
      </div>
      <button
        type="submit"
        disabled={loading}
        className="mt-[10px] w-full p-3 rounded-[10px] 
                  bg-gradient-to-[121deg] bg-[#74B11A] hover:bg-[#a1e043] text-white
                  transition-all duration-300 ease-in-out 
                  font-medium text-sm cursor-pointer"
      >
        {loading ? "Verifying..." : "Verify OTP"}
      </button>
    </form>
  );
};

VerifyOtpForm.propTypes = {
  email: PropTypes.string.isRequired,
  onVerified: PropTypes.func.isRequired,
};

export default VerifyOtpForm;
