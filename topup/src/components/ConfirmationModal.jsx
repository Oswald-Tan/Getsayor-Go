import { format } from "date-fns";
import PropTypes from "prop-types";
import PointIcon from "../assets/poin_cs.png";

const ConfirmationModal = ({
  show,
  onClose,
  onConfirm,
  selectedPoints,
  pointsOptions,
}) => {
  if (!show) return null;

  // Cari data berdasarkan poin yang dipilih
  const selectedOption = pointsOptions.find((p) => p.poin === selectedPoints);

  // Handle case ketika data tidak ditemukan
  if (!selectedOption) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-xl p-6 max-w-md w-full">
          <h2 className="text-xl font-bold mb-4 text-red-500">Error</h2>
          <p className="mb-4">Data paket poin tidak valid</p>
          <button
            onClick={onClose}
            className="w-full px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
          >
            Tutup
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-xl p-6 max-w-md w-full">
        <h2 className="text-xl font-bold mb-4">Konfirmasi Top Up</h2>

        <div className="space-y-3 mb-6">
          <div className="flex justify-between">
            <span className="text-gray-600">Poin:</span>
            <div className="flex items-center">
              <img src={PointIcon} alt="Poin" className="w-5 h-5 mr-2" />
              <span className="font-semibold">{selectedOption.poin}</span>
            </div>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-600">Jumlah:</span>
            <span className="font-semibold">
              Rp {selectedOption.price?.toLocaleString() || 0}
            </span>
          </div>

          <div className="flex justify-between">
            <span className="text-gray-600">Tanggal:</span>
            <span className="font-semibold">
              {format(new Date(), "dd MMM yyyy - HH:mm")}
            </span>
          </div>
        </div>

        <div className="flex gap-4">
          <button
            onClick={onClose}
            className="flex-1 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
          >
            Batal
          </button>
          <button
            onClick={onConfirm}
            className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            Konfirmasi
          </button>
        </div>
      </div>
    </div>
  );
};

ConfirmationModal.propTypes = {
  show: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
  onConfirm: PropTypes.func.isRequired,
  selectedPoints: PropTypes.number,
  pointsOptions: PropTypes.arrayOf(
    PropTypes.shape({
      poin: PropTypes.number.isRequired,
      price: PropTypes.number.isRequired,
      discountPercentage: PropTypes.number,
    })
  ).isRequired,
};

export default ConfirmationModal;
