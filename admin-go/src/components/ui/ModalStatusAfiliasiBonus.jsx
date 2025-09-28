import { motion, AnimatePresence } from "framer-motion";
import { X, CheckCircle } from "lucide-react";
import PropTypes from "prop-types";
import { useState, useEffect } from "react";
import axios from "axios";
import { API_URL } from "../../config";
import Swal from "sweetalert2";

const ModalStatusAfiliasiBonus = ({
  bonus = {},
  onClose = () => {},
  onStatusUpdate = () => {},
}) => {
  const [status, setStatus] = useState(bonus.status || "");
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (bonus.status) {
      setStatus(bonus.status);
    }
  }, [bonus]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      // Kirim request update status
      await axios.patch(`${API_URL}/afiliasi-bonus/${bonus.id}/transfer`);

      Swal.fire({
        icon: "success",
        title: "Success!",
        text: "Status bonus berhasil diubah menjadi transferred",
      });

      // Panggil callback untuk update data di parent component
      onStatusUpdate();

      // Tutup modal
      onClose();
    } catch (error) {
      console.error("Error updating status:", error);
      Swal.fire({
        icon: "error",
        title: "Error!",
        text: error.response?.data?.message || "Gagal mengubah status bonus",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AnimatePresence>
      {bonus && (
        <motion.div
          className="fixed inset-0 flex items-center justify-center bg-black/60 backdrop-blur-sm z-50 p-4"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
          onClick={onClose}
        >
          <motion.div
            className="bg-white rounded-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden shadow-2xl"
            initial={{ scale: 0.9, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0.9, opacity: 0, y: 20 }}
            transition={{
              duration: 0.3,
              type: "spring",
              damping: 25,
              stiffness: 300,
            }}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="relative bg-gradient-to-r from-blue-600 to-purple-600 px-8 py-6 text-white">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-2xl font-bold">Ubah Status Bonus</h2>
                  <p className="text-blue-100 mt-1">ID: #{bonus.id || "-"}</p>
                </div>
                <button
                  onClick={onClose}
                  className="p-2 hover:bg-white/20 rounded-full transition-colors duration-200"
                >
                  <X size={24} />
                </button>
              </div>
            </div>

            {/* Content */}
            <div className="overflow-y-auto max-h-[calc(90vh-120px)] p-6">
              <div className="mb-6">
                <div className="grid grid-cols-2 gap-4 mb-4">
                  <div>
                    <p className="text-sm text-gray-500">Nama Penerima</p>
                    <p className="font-medium">{bonus.user?.fullname || "-"}</p>
                  </div>

                  <div>
                    <p className="text-sm text-gray-500">Jumlah Bonus</p>
                    <p className="font-medium text-green-600">
                      Rp {bonus.bonus_amount?.toLocaleString("id-ID") || "0"}
                    </p>
                  </div>

                  <div>
                    <p className="text-sm text-gray-500">Status Saat Ini</p>
                    <p className="font-medium">
                      {bonus.status === "pending" ? (
                        <span className="px-2 py-1 text-xs text-white bg-orange-600 rounded-lg">
                          Pending
                        </span>
                      ) : bonus.status === "claimed" ? (
                        <span className="px-2 py-1 text-xs text-white bg-green-600 rounded-lg">
                          Claimed
                        </span>
                      ) : bonus.status === "expired" ? (
                        <span className="px-2 py-1 text-xs text-white bg-blue-600 rounded-lg">
                          Expired
                        </span>
                      ) : (
                        <span className="px-2 py-1 text-xs text-white bg-purple-600 rounded-lg">
                          Transferred
                        </span>
                      )}
                    </p>
                  </div>

                  <div>
                    <p className="text-sm text-gray-500">Tanggal Klaim</p>
                    <p className="font-medium">
                      {bonus.claimed_at
                        ? new Date(bonus.claimed_at).toLocaleDateString("id-ID")
                        : "-"}
                    </p>
                  </div>
                </div>

                <div className="bg-gray-50 rounded-lg p-4 mb-4">
                  <h3 className="font-medium text-gray-900 mb-2">
                    Informasi Rekening
                  </h3>
                  {bonus.user?.bank ? (
                    <div className="space-y-2">
                      <div>
                        <p className="text-sm text-gray-500">Bank</p>
                        <p className="font-medium">
                          {bonus.user.bank.bank_name || "-"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Nomor Rekening</p>
                        <p className="font-medium">
                          {bonus.user.bank.account_number || "-"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Atas Nama</p>
                        <p className="font-medium">
                          {bonus.user.bank.account_holder || "-"}
                        </p>
                      </div>
                    </div>
                  ) : (
                    <p className="text-gray-500 text-sm">
                      Tidak ada informasi rekening
                    </p>
                  )}
                </div>
              </div>

              <form onSubmit={handleSubmit}>
                <div className="mb-6">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Ubah Status Menjadi
                  </label>

                  <div className="flex items-center">
                    <input
                      type="radio"
                      id="transferred"
                      name="status"
                      value="transferred"
                      checked={status === "transferred"}
                      onChange={() => setStatus("transferred")}
                      className="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300"
                    />
                    <label
                      htmlFor="transferred"
                      className="ml-3 flex items-center"
                    >
                      <span className="block text-sm font-medium text-gray-700">
                        Transferred
                      </span>
                      <span className="ml-2 px-2 py-1 text-xs text-white bg-purple-600 rounded-lg">
                        Sudah ditransfer
                      </span>
                    </label>
                  </div>

                  <p className="mt-2 text-sm text-gray-500">
                    Menandakan bahwa bonus sudah ditransfer ke rekening penerima
                  </p>
                </div>

                <div className="flex justify-end gap-3">
                  <button
                    type="button"
                    onClick={onClose}
                    disabled={isLoading}
                    className="px-4 py-2 text-sm bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors disabled:opacity-50"
                  >
                    Batal
                  </button>
                  <button
                    type="submit"
                    disabled={isLoading || status !== "transferred"}
                    className={`px-4 py-2 text-sm text-white rounded-md transition-colors flex items-center ${
                      isLoading || status !== "transferred"
                        ? "bg-gray-400 cursor-not-allowed"
                        : "bg-purple-600 hover:bg-purple-700"
                    }`}
                  >
                    {isLoading ? (
                      <>
                        <svg
                          className="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
                          xmlns="http://www.w3.org/2000/svg"
                          fill="none"
                          viewBox="0 0 24 24"
                        >
                          <circle
                            className="opacity-25"
                            cx="12"
                            cy="12"
                            r="10"
                            stroke="currentColor"
                            strokeWidth="4"
                          ></circle>
                          <path
                            className="opacity-75"
                            fill="currentColor"
                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                          ></path>
                        </svg>
                        Memproses...
                      </>
                    ) : (
                      <>
                        <CheckCircle className="w-4 h-4 mr-1" />
                        Simpan Status
                      </>
                    )}
                  </button>
                </div>
              </form>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

ModalStatusAfiliasiBonus.propTypes = {
  afiliasi: PropTypes.object,
  bonus: PropTypes.object.isRequired,
  onClose: PropTypes.func.isRequired,
  onStatusUpdate: PropTypes.func.isRequired,
};

export default ModalStatusAfiliasiBonus;
