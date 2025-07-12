import express from "express";
import { getProducts, getProductById, createProduct, updateProduct, deleteProduct } from "../../controllers/productController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";
import { upload } from "../../middleware/upload.js";

const router = express.Router();

router.get('/', verifyUser, adminOnly, getProducts);
router.get('/:id', verifyUser, adminOnly, getProductById);
router.post('/', verifyUser, adminOnly, upload.single('image'), createProduct);
router.patch('/:id', verifyUser, adminOnly, upload.single('image'), updateProduct);
router.delete('/:id', verifyUser, adminOnly, deleteProduct);

export default router;