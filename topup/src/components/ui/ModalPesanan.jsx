import { motion, AnimatePresence } from "framer-motion";
import PropTypes from "prop-types";
import { formatShortDate } from "../../utils/formateDate";
import { IoIosCloseCircleOutline } from "react-icons/io";
import CSPoin from "../../assets/poin_cs.png";
import { API_URL_STATIC } from "../../config";

const ModalPesanan = ({ pesanan, onClose }) => {
  return (
    <AnimatePresence>
      {pesanan && (
        <motion.div
          className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-40 p-5"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
        >
          <motion.div
            className="bg-white rounded-lg w-[600px] max-h-[600px] relative overflow-x-auto"
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.8, opacity: 0 }}
            transition={{ duration: 0.3 }}
          >
            <div className="py-4 px-5 bg-gray-100 rounded-t-lg">
              <p>#{pesanan.invoiceNumber || "-"}</p>
              <p className="text-xs mt-2 text-gray-500">Detail Pesanan</p>
            </div>
            <div className="p-5 ">
              <div className="flex gap-x-5 md:gap-x-10">
                <div>
                  <p className="text-xs text-gray-500">Create at</p>
                  <p className="mt-2 text-sm">
                    {formatShortDate(pesanan.created_at)}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-gray-500 mb-1">Payment</p>
                  {pesanan.paymentStatus === "unpaid" ? (
                    <span className="px-2 py-1 text-xs text-yellow-500 border border-yellow-500 rounded-lg">
                      Unpaid
                    </span>
                  ) : pesanan.paymentStatus === "paid" ? (
                    <span className="px-2 py-1 text-xs text-green-600 border border-green-600 rounded-lg">
                      Paid
                    </span>
                  ) : null}
                </div>
                <div>
                  <p className="text-xs text-gray-500 mb-1">Status</p>
                  {pesanan.status === "pending" ? (
                    <span className="px-2 py-1 text-xs text-white bg-orange-600 rounded-lg">
                      Pending
                    </span>
                  ) : pesanan.status === "confirmed" ? (
                    <span className="px-2 py-1 text-xs text-white bg-green-600 rounded-lg">
                      Confirmed
                    </span>
                  ) : pesanan.status === "processed" ? (
                    <span className="px-2 py-1 text-xs text-white bg-blue-600 rounded-lg">
                      Processed
                    </span>
                  ) : pesanan.status === "out-for-delivery" ? (
                    <span className="px-2 py-1 text-xs text-white bg-yellow-600 rounded-lg">
                      Out for Delivery
                    </span>
                  ) : pesanan.status === "delivered" ? (
                    <span className="px-2 py-1 text-xs text-white bg-gray-600 rounded-lg">
                      Delivered
                    </span>
                  ) : (
                    <span className="px-2 py-1 text-xs text-white bg-red-600 rounded-lg">
                      Cancelled
                    </span>
                  )}
                </div>
              </div>

              <hr className="border-t border-gray-200 my-4" />

              <div className="flex flex-col md:flex-row justify-between gap-4 md:gap-20">
                <div>
                  <p className="text-xs text-gray-500 mb-2">Customer</p>
                  <p className="text-sm">
                    {pesanan.user?.userDetails?.fullname || "-"}
                  </p>
                  <p className="text-sm mt-2 text-blue-500">
                    {pesanan.user?.email || "-"}
                  </p>
                  <p className="text-sm mt-2">
                    {pesanan?.user?.user[0]?.phone_number || "-"}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-gray-500 mb-2">Address</p>
                  <p className="text-sm mt-2">
                    {pesanan?.user?.user?.length > 0 &&
                    pesanan?.user?.user[0]?.address_line_1
                      ? `${pesanan.user.user[0].address_line_1}, ${pesanan.user.user[0].city}`
                      : "-"}
                  </p>
                </div>
              </div>

              <hr className="border-t border-gray-200 my-4" />
              <div>
                <p className="text-xs text-gray-500 mb-2">Produk</p>
                <ul className="text-sm grid grid-cols-1 md:grid-cols-2 gap-2">
                  {pesanan.orderItems.map((item) => (
                    <li key={item.id}>
                      <div className="flex items-center gap-2 bg-gray-100 rounded-lg p-2 w-full">
                        <div className="flex p-1 bg-white rounded-lg w-12 h-12">
                          <img
                            src={
                              item.produk?.image
                                ? `${API_URL_STATIC}/${item.produk.image}`
                                : "../../assets/placeholder.png"
                            }
                            alt={item.namaProduk}
                            className="w-full object-cover rounded-lg"
                          />
                        </div>
                        <div className="flex flex-col">
                          <p className="text-xs">
                            {item.namaProduk} ({item.berat}{" "}
                            {item.satuan === "Gram"
                              ? "gr"
                              : item.satuan === "Kilogram"
                              ? "kg"
                              : item.satuan}
                            )
                          </p>

                          <p className="text-xs">
                            {pesanan.hargaPoin ? (
                              <span>{`${item.totalHarga} Poin`}</span>
                            ) : pesanan.hargaRp ? (
                              <span>
                                Rp. {item.totalHarga.toLocaleString("id-ID")}
                              </span>
                            ) : (
                              "-"
                            )}
                          </p>
                        </div>
                      </div>
                    </li>
                  ))}
                </ul>
              </div>

              <hr className="border-t border-gray-200 my-4" />

              <div>
                <p className="text-xs text-gray-500 mb-2">Payment</p>
                <div className="flex justify-between">
                  <p className="text-sm">Subtotal</p>
                  <div>
                    {pesanan.hargaPoin ? (
                      <div className="flex items-center justify-center gap-1">
                        <img src={CSPoin} alt="poin" className="w-4" />
                        <span className="text-sm">{`${pesanan.hargaPoin} Poin`}</span>
                      </div>
                    ) : pesanan.hargaRp ? (
                      <span className="text-sm">
                        Rp. {pesanan.hargaRp.toLocaleString("id-ID")}
                      </span>
                    ) : (
                      "-"
                    )}
                  </div>
                </div>
              </div>

              <div className="flex justify-between">
                <p className="text-sm">Ongkir</p>
                <div>
                  {pesanan.hargaPoin ? (
                    <div className="flex items-center justify-center gap-1">
                      <img src={CSPoin} alt="poin" className="w-4" />
                      <span className="text-sm">{`${pesanan.ongkir} Poin`}</span>
                    </div>
                  ) : pesanan.hargaRp ? (
                    <span className="text-sm">
                      Rp. {pesanan.ongkir.toLocaleString("id-ID")}
                    </span>
                  ) : (
                    "-"
                  )}
                </div>
              </div>
              <div className="flex justify-between mt-2">
                <p className="text-sm font-semibold">Total</p>
                <div>
                  {pesanan.hargaPoin ? (
                    <div className="flex items-center justify-center gap-1">
                      <img src={CSPoin} alt="poin" className="w-4" />
                      <span className="text-sm font-semibold">{`${pesanan.totalBayar} Poin`}</span>
                    </div>
                  ) : pesanan.hargaRp ? (
                    <span className="text-sm font-semibold">
                      Rp. {pesanan.totalBayar.toLocaleString("id-ID")}
                    </span>
                  ) : (
                    "-"
                  )}
                </div>
              </div>

              <button
                onClick={onClose}
                className="mt-4 text-sm absolute top-0 right-3 text-gray-500"
              >
                <IoIosCloseCircleOutline size={23} />
              </button>
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
