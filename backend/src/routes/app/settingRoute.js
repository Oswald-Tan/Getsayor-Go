import express from "express";
import { getHargaPoin, setHargaPoin } from "../../controllers/settingController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";

const router = express.Router();

router.get('/harga-poin', authMiddleware, checkTokenBlacklist, getHargaPoin);
router.post('/harga-poin', authMiddleware, checkTokenBlacklist, setHargaPoin);

export default router;