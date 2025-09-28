import { motion, AnimatePresence } from "framer-motion";
import PropTypes from "prop-types";
import { IoIosCloseCircleOutline } from "react-icons/io";
import CSPoin from "../../assets/poin_cs.png";
import { API_URL_STATIC } from "../../config";

const ModalProduct = ({ product, onClose }) => {
  const firstVariant = product?.productItems?.[0] || {};

  return (
    <AnimatePresence>
      {product && (
        <motion.div
          className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-40 p-5"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
        >
          <motion.div
            className="bg-white rounded-lg w-[500px] max-h-[600px] relative overflow-x-auto"
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.8, opacity: 0 }}
            transition={{ duration: 0.3 }}
          >
            <div className="p-5 ">
              <p className="font-semibold mb-5">Detail Produk</p>
              <img
                src={
                  product.image
                    ? `${API_URL_STATIC}/${product.image}`
                    : "../../assets/placeholder.png"
                }
                alt={product.nameProduk}
                className="w-[400px] object-cover rounded-lg mx-auto"
              />
              <p className="mt-4 font-semibold text-xl">{product.nameProduk}</p>

              <div className="mt-3 flex justify-between items-center">
                <div>
                  <div className="flex gap-1 items-center">
                    <img src={CSPoin} alt="CS Poin" className="w-5 h-5" />
                    <p className="font-semibold">{firstVariant.hargaPoin || 0}</p>
                  </div>
                  <p className="text-gray-500 text-xs mt-1">
                    Rp. {firstVariant.hargaRp?.toLocaleString("id-ID") || "0"}
                  </p>
                </div>
                <p className="text-sm font-semibold">{firstVariant.jumlah} {firstVariant.satuan}</p>
              </div>

              <p className="text-md font-semibold mt-3">Deskripsi Produk</p>
              <p className="text-gray-500 text-sm mt-2">{product.deskripsi}</p>

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

ModalProduct.propTypes = {
  product: PropTypes.object.isRequired,
  onClose: PropTypes.func.isRequired,
};

export default ModalProduct;
