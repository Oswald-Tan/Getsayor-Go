import express from "express";
import { getHargaPoin, getHargaPoinById, createHargaPoin, updateHargaPoin, deleteHargaPoin } from "../../controllers/hargaPoinController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";
const router = express.Router();

router.get('/', authMiddleware, checkTokenBlacklist, getHargaPoin);
router.get('/:id', authMiddleware, checkTokenBlacklist, getHargaPoinById);
router.post('/', authMiddleware, checkTokenBlacklist, createHargaPoin);
router.patch('/:id', authMiddleware, checkTokenBlacklist, updateHargaPoin);
router.delete('/:id', authMiddleware, checkTokenBlacklist, deleteHargaPoin);

export default router;