import { motion, AnimatePresence } from 'framer-motion';
import { X, Calendar, CreditCard, Package, User, MapPin, ShoppingBag } from 'lucide-react';
import { API_URL_STATIC } from '../../config';
import PropTypes from "prop-types"

// Mock data untuk demonstrasi
const mockPesanan = {
  InvoiceNumber: "INV-2024-001234",
  CreatedAt: "2024-01-15T10:30:00Z",
  PaymentStatus: "paid",
  Status: "processed",
  User: {
    Details: {
      Fullname: "Ahmad Rizki Pratama"
    },
    Email: "ahmad.rizki@email.com",
    PhoneNumber: "+62 812-3456-7890",
    Addresses: [{
      ID: 1,
      IsDefault: true,
      RecipientName: "Ahmad Rizki Pratama",
      PhoneNumber: "+62 812-3456-7890",
      AddressLine1: "Jl. Sudirman No. 123, RT 05/RW 02",
      City: "Jakarta Selatan",
      State: "DKI Jakarta",
      PostalCode: "12190"
    }]
  },
  OrderItems: [
    {
      ID: 1,
      NamaProduk: "Beras Premium",
      Berat: 5,
      Satuan: "Kilogram",
      TotalHarga: 75000,
      Product: {
        Image: null
      }
    },
    {
      ID: 2,
      NamaProduk: "Minyak Goreng",
      Berat: 2,
      Satuan: "Liter",
      TotalHarga: 35000,
      Product: {
        Image: null
      }
    }
  ],
  HargaRp: 110000,
  Ongkir: 15000,
  TotalBayar: 125000
};

const ModalPesanan = ({ pesanan = mockPesanan, onClose = () => {} }) => {
  const formatShortDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('id-ID', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getStatusConfig = (status) => {
    const configs = {
      pending: { bg: 'bg-amber-100', text: 'text-amber-800', border: 'border-amber-200', label: 'Pending' },
      confirmed: { bg: 'bg-emerald-100', text: 'text-emerald-800', border: 'border-emerald-200', label: 'Confirmed' },
      processed: { bg: 'bg-blue-100', text: 'text-blue-800', border: 'border-blue-200', label: 'Processed' },
      'out-for-delivery': { bg: 'bg-purple-100', text: 'text-purple-800', border: 'border-purple-200', label: 'Out for Delivery' },
      delivered: { bg: 'bg-gray-100', text: 'text-gray-800', border: 'border-gray-200', label: 'Delivered' },
      cancelled: { bg: 'bg-red-100', text: 'text-red-800', border: 'border-red-200', label: 'Cancelled' }
    };
    return configs[status] || configs.pending;
  };

  const getPaymentConfig = (status) => {
    const configs = {
      unpaid: { bg: 'bg-orange-100', text: 'text-orange-800', border: 'border-orange-200', label: 'Unpaid' },
      paid: { bg: 'bg-green-100', text: 'text-green-800', border: 'border-green-200', label: 'Paid' }
    };
    return configs[status] || configs.unpaid;
  };

  const statusConfig = getStatusConfig(pesanan.Status);
  const paymentConfig = getPaymentConfig(pesanan.PaymentStatus);

  return (
    <AnimatePresence>
      {pesanan && (
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
            transition={{ duration: 0.3, type: "spring", damping: 25, stiffness: 300 }}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="relative bg-gradient-to-r from-blue-600 to-purple-600 px-8 py-6 text-white">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-2xl font-bold">{pesanan.InvoiceNumber || "-"}</h2>
                  <p className="text-blue-100 mt-1">Order Details</p>
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
            <div className="overflow-y-auto max-h-[calc(90vh-120px)]">
              <div className="p-8 space-y-8">
                {/* Status Cards */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-2 bg-blue-100 rounded-lg">
                        <Calendar className="w-5 h-5 text-blue-600" />
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Created At</p>
                        <p className="font-semibold text-gray-900">
                          {formatShortDate(pesanan.CreatedAt)}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-2 bg-green-100 rounded-lg">
                        <CreditCard className="w-5 h-5 text-green-600" />
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Payment Status</p>
                        <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium border ${paymentConfig.bg} ${paymentConfig.text} ${paymentConfig.border}`}>
                          {paymentConfig.label}
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-2 bg-purple-100 rounded-lg">
                        <Package className="w-5 h-5 text-purple-600" />
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Order Status</p>
                        <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium border ${statusConfig.bg} ${statusConfig.text} ${statusConfig.border}`}>
                          {statusConfig.label}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Customer & Address Info */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="p-2 bg-blue-100 rounded-lg">
                        <User className="w-5 h-5 text-blue-600" />
                      </div>
                      <h3 className="text-lg font-semibold text-gray-900">Customer Information</h3>
                    </div>
                    <div className="space-y-3">
                      <div>
                        <p className="text-sm text-gray-500">Full Name</p>
                        <p className="font-medium text-gray-900">
                          {pesanan.User?.Details?.Fullname || "-"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Email</p>
                        <p className="font-medium text-blue-600">
                          {pesanan.User?.Email || "-"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Phone</p>
                        <p className="font-medium text-gray-900">
                          {pesanan.User?.Details.PhoneNumber || "-"}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="p-2 bg-green-100 rounded-lg">
                        <MapPin className="w-5 h-5 text-green-600" />
                      </div>
                      <h3 className="text-lg font-semibold text-gray-900">Delivery Address</h3>
                    </div>
                    {pesanan.User?.Addresses?.length > 0 ? (
                      pesanan.User.Addresses.filter(addr => addr.IsDefault).map(address => (
                        <div key={address.ID} className="space-y-2">
                          <p className="font-medium text-gray-900">{address.RecipientName}</p>
                          <p className="text-gray-700">{address.PhoneNumber}</p>
                          <p className="text-gray-700">{address.AddressLine1}</p>
                          <p className="text-gray-700">
                            {address.City}, {address.State} {address.PostalCode}
                          </p>
                        </div>
                      ))
                    ) : (
                      <p className="text-gray-500">No address available</p>
                    )}
                  </div>
                </div>

                {/* Products */}
                <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="p-2 bg-purple-100 rounded-lg">
                      <ShoppingBag className="w-5 h-5 text-purple-600" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900">Order Items</h3>
                  </div>
                  
                  <div className="space-y-4">
                    {pesanan.OrderItems?.length > 0 ? (
                      pesanan.OrderItems.map((item) => (
                        <div key={item.ID} className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-200">
                          <div className="flex items-center gap-4">
                            <div className="flex-shrink-0 w-16 h-16 bg-gray-100 rounded-lg overflow-hidden">
                             <img
                              src={
                                item.ProductItem.Product?.Image
                                  ? `${API_URL_STATIC}/${item.ProductItem.Product.Image}`
                                  : "../../assets/placeholder.png"
                              }
                              alt={item.NamaProduk}
                              className="w-full object-cover rounded-lg"
                            />
                            </div>
                            <div className="flex-grow">
                              <h4 className="font-semibold text-gray-900">{item.NamaProduk}</h4>
                              <p className="text-sm text-gray-600">
                                {item.Berat} {item.Satuan === "Gram" ? "gr" : item.Satuan === "Kilogram" ? "kg" : item.Satuan}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="font-semibold text-gray-900">
                                {pesanan.HargaPoin ? (
                                  `${item.TotalHarga} Points`
                                ) : (
                                  `Rp ${item.TotalHarga.toLocaleString("id-ID")}`
                                )}
                              </p>
                            </div>
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="text-center py-8 text-gray-500">
                        <Package className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                        <p>No items in this order</p>
                      </div>
                    )}
                  </div>
                </div>

                {/* Payment Summary */}
                <div className="bg-gradient-to-r from-gray-50 to-blue-50 rounded-xl p-6 border border-gray-100">
                  <h3 className="text-lg font-semibold text-gray-900 mb-6">Payment Summary</h3>
                  <div className="space-y-4">
                    <div className="flex justify-between items-center">
                      <span className="text-gray-600">Subtotal</span>
                      <span className="font-medium text-gray-900">
                        {pesanan.HargaPoin ? (
                          `${pesanan.HargaPoin} Points`
                        ) : (
                          `Rp ${pesanan.HargaRp?.toLocaleString("id-ID") || 0}`
                        )}
                      </span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-gray-600">Shipping Cost</span>
                      <span className="font-medium text-gray-900">
                        {pesanan.HargaPoin ? (
                          `${pesanan.Ongkir} Points`
                        ) : (
                          `Rp ${pesanan.Ongkir?.toLocaleString("id-ID") || 0}`
                        )}
                      </span>
                    </div>
                    <div className="border-t border-gray-200 pt-4">
                      <div className="flex justify-between items-center">
                        <span className="text-xl font-bold text-gray-900">Total</span>
                        <span className="text-xl font-bold text-blue-600">
                          {pesanan.HargaPoin ? (
                            `${pesanan.TotalBayar} Points`
                          ) : (
                            `Rp ${pesanan.TotalBayar?.toLocaleString("id-ID") || 0}`
                          )}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

ModalPesanan.propTypes = {
  pesanan: PropTypes.object.isRequired,
  onClose: PropTypes.func.isRequired,
};

export default ModalPesanan;