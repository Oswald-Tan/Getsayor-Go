import express from "express";
import { claimBonus, getTotalBonus, getPendingBonus, getExpiredBonus } from "../../controllers/afiliasiBonusController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";
const router = express.Router();

router.post('/claim', authMiddleware, checkTokenBlacklist, claimBonus);
router.get('/total/:userId', authMiddleware, checkTokenBlacklist, getTotalBonus);
router.get('/pending/:userId', authMiddleware, checkTokenBlacklist, getPendingBonus);
router.get('/expired/:userId', authMiddleware, checkTokenBlacklist, getExpiredBonus);

export default router;