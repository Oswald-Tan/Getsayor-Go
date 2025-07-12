import express from "express";
import { createOrUpdateBankAccount, getBankAccountByUserId, deleteBankAccount } from "../../controllers/bankAccountController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";
const router = express.Router();


router.post('/', authMiddleware, checkTokenBlacklist, createOrUpdateBankAccount);
router.get('/:userId', authMiddleware, checkTokenBlacklist, getBankAccountByUserId);
router.delete('/:userId', authMiddleware, checkTokenBlacklist, deleteBankAccount);

export default router;