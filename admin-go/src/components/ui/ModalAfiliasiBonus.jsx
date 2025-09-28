import { motion, AnimatePresence } from 'framer-motion';
import { X, Calendar, Wallet, User, Banknote, Gift, UserCheck } from 'lucide-react';
import PropTypes from "prop-types"

const ModalAfiliasiBonus = ({ afiliasi = {}, onClose = () => {} }) => {
  const formatShortDate = (dateString) => {
    if (!dateString) return '-';
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
      pending: { 
        bg: 'bg-amber-100', 
        text: 'text-amber-800', 
        border: 'border-amber-200', 
        label: 'Pending',
        icon: <Banknote className="w-4 h-4" />
      },
      claimed: { 
        bg: 'bg-emerald-100', 
        text: 'text-emerald-800', 
        border: 'border-emerald-200', 
        label: 'Claimed',
        icon: <Wallet className="w-4 h-4" />
      },
      expired: { 
        bg: 'bg-gray-100', 
        text: 'text-gray-800', 
        border: 'border-gray-200', 
        label: 'Expired',
        icon: <Calendar className="w-4 h-4" />
      },
      transferred: { 
        bg: 'bg-purple-100', 
        text: 'text-purple-800', 
        border: 'border-purple-200', 
        label: 'Transferred',
        icon: <Gift className="w-4 h-4" />
      }
    };
    return configs[status] || configs.pending;
  };

  const statusConfig = getStatusConfig(afiliasi.status);

  return (
    <AnimatePresence>
      {afiliasi && (
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
                  <h2 className="text-2xl font-bold">Afiliasi Bonus Details</h2>
                  <p className="text-blue-100 mt-1">ID: #{afiliasi.id || "-"}</p>
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
              <div className="p-6 space-y-6">
                {/* Status Cards */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-2 bg-blue-100 rounded-lg">
                        <Calendar className="w-5 h-5 text-blue-600" />
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Expiry Date</p>
                        <p className="font-semibold text-gray-900">
                          {formatShortDate(afiliasi.expiry_date)}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-2 bg-green-100 rounded-lg">
                        <Wallet className="w-5 h-5 text-green-600" />
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Bonus Amount</p>
                        <p className="font-semibold text-green-600">
                          Rp {afiliasi.bonus_amount?.toLocaleString("id-ID") || "0"}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-2 bg-purple-100 rounded-lg">
                        <Gift className="w-5 h-5 text-purple-600" />
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Bonus Status</p>
                        <div className="flex items-center gap-1">
                          <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium border ${statusConfig.bg} ${statusConfig.text} ${statusConfig.border}`}>
                            {statusConfig.icon}
                            <span className="ml-1">{statusConfig.label}</span>
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* User & Referral Info */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                  {/* User Information */}
                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="p-2 bg-blue-100 rounded-lg">
                        <User className="w-5 h-5 text-blue-600" />
                      </div>
                      <h3 className="text-lg font-semibold text-gray-900">Recipient Information</h3>
                    </div>
                    <div className="space-y-3">
                      <div>
                        <p className="text-sm text-gray-500">Full Name</p>
                        <p className="font-medium text-gray-900">
                          {afiliasi.user?.fullname || "-"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Email</p>
                        <p className="font-medium text-blue-600">
                          {afiliasi.user?.email || "-"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Phone</p>
                        <p className="font-medium text-gray-900">
                          {afiliasi.user?.phone || "-"}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Referral User */}
                  <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="p-2 bg-green-100 rounded-lg">
                        <UserCheck className="w-5 h-5 text-green-600" />
                      </div>
                      <h3 className="text-lg font-semibold text-gray-900">Referral User</h3>
                    </div>
                    <div className="space-y-3">
                      <div>
                        <p className="text-sm text-gray-500">Email</p>
                        <p className="font-medium text-gray-900">
                          {afiliasi.referral_user?.email || "-"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Level</p>
                        <p className="font-medium text-blue-600">
                          Level {afiliasi.bonus_level || "-"}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Order ID</p>
                        <p className="font-medium text-gray-900">
                          {afiliasi.pesanan?.order_id || "-"}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Bank Account */}
                <div className="bg-gray-50 rounded-xl p-6 border border-gray-100">
                  <div className="flex items-center gap-3 mb-6">
                    <div className="p-2 bg-purple-100 rounded-lg">
                      <Wallet className="w-5 h-5 text-purple-600" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900">Bank Account</h3>
                  </div>
                  
                  {afiliasi.user?.bank ? (
                    <div className="bg-white rounded-lg p-4 border border-gray-200 shadow-sm">
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div>
                          <p className="text-sm text-gray-500">Account Holder</p>
                          <p className="font-semibold text-gray-900">
                            {afiliasi.user.bank.account_holder || "-"}
                          </p>
                        </div>
                        <div>
                          <p className="text-sm text-gray-500">Bank Name</p>
                          <p className="font-semibold text-gray-900">
                            {afiliasi.user.bank.bank_name || "-"}
                          </p>
                        </div>
                        <div>
                          <p className="text-sm text-gray-500">Account Number</p>
                          <p className="font-semibold text-gray-900">
                            {afiliasi.user.bank.account_number || "-"}
                          </p>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div className="text-center py-6 text-gray-500 bg-white rounded-lg border border-gray-200">
                      <Wallet className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                      <p>No bank account available</p>
                    </div>
                  )}
                </div>

                {/* Timeline */}
                <div className="bg-gradient-to-r from-gray-50 to-blue-50 rounded-xl p-6 border border-gray-100">
                  <h3 className="text-lg font-semibold text-gray-900 mb-6">Bonus Timeline</h3>
                  <div className="space-y-6">
                    <div className="flex items-start">
                      <div className="flex flex-col items-center mr-4">
                        <div className="bg-blue-500 rounded-full p-2">
                          <Calendar className="w-4 h-4 text-white" />
                        </div>
                        <div className="w-px h-full bg-gray-300 mt-2"></div>
                      </div>
                      <div className="flex-grow">
                        <p className="font-medium text-gray-900">Bonus Received</p>
                        <p className="text-sm text-gray-500">
                          {formatShortDate(afiliasi.bonus_received_at)}
                        </p>
                      </div>
                    </div>

                    {afiliasi.claimed_at && (
                      <div className="flex items-start">
                        <div className="flex flex-col items-center mr-4">
                          <div className="bg-green-500 rounded-full p-2">
                            <Wallet className="w-4 h-4 text-white" />
                          </div>
                          <div className="w-px h-full bg-gray-300 mt-2"></div>
                        </div>
                        <div className="flex-grow">
                          <p className="font-medium text-gray-900">Claimed</p>
                          <p className="text-sm text-gray-500">
                            {formatShortDate(afiliasi.claimed_at)}
                          </p>
                        </div>
                      </div>
                    )}

                    {afiliasi.transferred_at && (
                      <div className="flex items-start">
                        <div className="flex flex-col items-center mr-4">
                          <div className="bg-purple-500 rounded-full p-2">
                            <Gift className="w-4 h-4 text-white" />
                          </div>
                        </div>
                        <div className="flex-grow">
                          <p className="font-medium text-gray-900">Transferred</p>
                          <p className="text-sm text-gray-500">
                            {formatShortDate(afiliasi.transferred_at)}
                          </p>
                        </div>
                      </div>
                    )}

                    {!afiliasi.transferred_at && afiliasi.expiry_date && (
                      <div className="flex items-start">
                        <div className="flex flex-col items-center mr-4">
                          <div className="bg-gray-500 rounded-full p-2">
                            <Calendar className="w-4 h-4 text-white" />
                          </div>
                        </div>
                        <div className="flex-grow">
                          <p className="font-medium text-gray-900">Expiry Date</p>
                          <p className="text-sm text-gray-500">
                            {formatShortDate(afiliasi.expiry_date)}
                          </p>
                        </div>
                      </div>
                    )}
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

ModalAfiliasiBonus.propTypes = {
  afiliasi: PropTypes.object.isRequired,
  onClose: PropTypes.func.isRequired,
};

export default ModalAfiliasiBonus;