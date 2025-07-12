import express from "express";
import { postTopUp, getTopUp, updateTopUpStatus, getTopUpById, getTopUpByUserId } from "../../controllers/topUpPoinController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";

const router = express.Router();

router.post("/", authMiddleware, checkTokenBlacklist, postTopUp);
router.get("/", authMiddleware, checkTokenBlacklist, getTopUp);
router.get("/user", authMiddleware, checkTokenBlacklist, getTopUpByUserId);
router.get("/:id", authMiddleware, checkTokenBlacklist, getTopUpById);
router.post("/cancel/:id", authMiddleware, checkTokenBlacklist, updateTopUpStatus);

export default router;
