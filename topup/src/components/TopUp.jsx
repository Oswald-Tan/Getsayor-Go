import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import ConfirmationModal from "./ConfirmationModal.jsx";
import PointIcon from "../assets/poin_cs.png";
import { API_URL } from "../config.jsx";

const TopUp = () => {
  const [pointsOptions, setPointsOptions] = useState([]);
  const [selectedPoints, setSelectedPoints] = useState(null);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [loading, setLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const fetchPoints = async () => {
      try {
        setLoading(true);
        const response = await axios.get(`${API_URL}/show-poin`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        });

        const responseData = response.data || [];
        const uniqueData = responseData.filter(
          (v, i, a) =>
            a.findIndex(
              (t) =>
                t.poin === v.poin &&
                t.price === v.price &&
                t.discountPercentage === v.discountPercentage
            ) === i
        );

        if (uniqueData.length === 0) {
          setErrorMessage("Tidak ada paket poin tersedia");
        } else {
          setErrorMessage("");
        }

        setPointsOptions(uniqueData);
      } catch (error) {
        console.error("Error fetching points:", error);
        setErrorMessage("Gagal memuat data poin. Silakan coba lagi.");
        setPointsOptions([]);
      } finally {
        setLoading(false);
      }
    };

    fetchPoints();
  }, []);

  const handleProceed = () => {
    if (selectedPoints) {
      setShowConfirmation(true);
    }
  };

  const handleConfirm = async () => {
    try {
      const selectedOption = pointsOptions.find(
        (p) => p.poin === selectedPoints
      );

      if (!selectedOption) {
        throw new Error("Pilihan poin tidak valid");
      }

      const response = await axios.post(
        `${API_URL}/topup-from-web`,
        {
          points: selectedOption.poin,
          price: selectedOption.price,
          bankName: "BCA",
        },
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );

      if (!response.data?.transactionId) {
        throw new Error("Gagal memproses top-up");
      }

      navigate("/invoice", {
        state: {
          ...response.data,
          bankName: "BCA",
          date: new Date().toISOString(),
          points: selectedOption.poin,
          price: selectedOption.price,
        },
      });
    } catch (error) {
      setErrorMessage(error.response?.data?.message || error.message);
      setShowConfirmation(false);
    }
  };

  const renderPoints = () => {
    if (loading) {
      return null; // Loading ditangani oleh komponen utama
    }

    if (errorMessage) {
      return (
        <div className="text-center py-8 text-red-500">{errorMessage}</div>
      );
    }

    if (pointsOptions.length === 0) {
      return (
        <div className="text-center py-8 text-gray-500">
          Tidak ada paket poin tersedia
        </div>
      );
    }

    return (
      <>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-2 md:gap-3">
          {pointsOptions.map((option) => {
            const uniqueKey = `poin-${option.poin}-${option.price}-${option.discountPercentage}`;
            const isSelected = selectedPoints === option.poin;

            return (
              <div
                key={uniqueKey}
                onClick={() =>
                  setSelectedPoints((prev) =>
                    prev === option.poin ? null : option.poin
                  )
                }
                className={`relative p-3 md:p-4 rounded-xl cursor-pointer transition-all 
          flex flex-col justify-between min-h-[112px] md:min-h-[120px]
          border-2 ${
            isSelected
              ? "bg-green-100 border-green-500 shadow-lg"
              : "bg-white border-gray-200 hover:bg-gray-50 hover:shadow-md"
          }`}
              >
                <div className="flex-1 flex items-center justify-between">
                  <div className="flex items-center gap-2 h-full">
                    <img
                      src={PointIcon}
                      alt="Poin"
                      className="w-6 h-6 md:w-7 md:h-7"
                    />
                    <span className="text-lg md:text-xl font-bold text-gray-800">
                      {option.poin}
                    </span>
                  </div>

                  <div className="absolute top-3 right-2 text-right">
                    <p className="font-semibold text-green-600 text-sm md:text-base">
                      Rp {option.price?.toLocaleString() || 0}
                    </p>
                    {option.discountPercentage > 0 && (
                      <p className="text-xs md:text-[13px] text-gray-400 line-through mt-[2px]">
                        Rp {option.originalPrice?.toLocaleString() || 0}
                      </p>
                    )}
                  </div>
                </div>

                {option.discountPercentage > 0 && (
                  <div className="absolute bottom-3 right-2">
                    <div
                      className="bg-red-100 text-red-600 px-2 py-1 rounded-full 
              text-[10px] md:text-xs font-medium tracking-wide"
                    >
                      {option.discountPercentage}% OFF
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>

        <button
          onClick={handleProceed}
          disabled={!selectedPoints}
          className={`w-full mt-6 py-3 md:py-4 rounded-lg font-medium text-white 
            transition-all md:text-lg
            ${
              selectedPoints
                ? "bg-green-600 hover:bg-green-700 hover:scale-[1.02]"
                : "bg-gray-400 cursor-not-allowed"
            }`}
        >
          Process
        </button>
      </>
    );
  };

  return (
    <div className="max-w-4xl mx-auto relative min-h-screen">
      {/* Loading Screen Overlay */}
      {loading && (
        <div className="fixed inset-0 bg-white bg-opacity-80 z-50 flex items-center justify-center">
          <div className="text-center">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-600 mb-4"></div>
            <p className="text-gray-700 font-medium">Memuat data poin...</p>
          </div>
        </div>
      )}

      <h1 className="text-2xl font-bold text-gray-800 mb-6 text-center pt-6">
        Top Up Poin
      </h1>

      {renderPoints()}

      <ConfirmationModal
        show={showConfirmation}
        onClose={() => setShowConfirmation(false)}
        onConfirm={handleConfirm}
        selectedPoints={selectedPoints}
        pointsOptions={pointsOptions}
      />

      {errorMessage && (
        <div className="mt-4 text-red-500 text-center">{errorMessage}</div>
      )}
    </div>
  );
};

export default TopUp;