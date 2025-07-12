import express from "express";
import { getProducts, getProductById, createProduct, updateProduct, deleteProduct, getProductsApp, searchProductsApp } from "../../controllers/productController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";

const router = express.Router();

router.get('/', authMiddleware, checkTokenBlacklist, getProducts);
router.get('/app', authMiddleware, checkTokenBlacklist, getProductsApp);
router.get('/search', authMiddleware, checkTokenBlacklist, searchProductsApp);
router.get('/:id', authMiddleware, checkTokenBlacklist, getProductById);
router.post('/', authMiddleware, checkTokenBlacklist, createProduct);
router.patch('/:id', authMiddleware, checkTokenBlacklist, updateProduct);
router.delete('/:id', authMiddleware, checkTokenBlacklist, deleteProduct);

export default router;