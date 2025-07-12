import express from "express";
import {
  getDiscountPoin,
  getDiscountPoinById,
  createDiscountPoin,
  updateDiscountPoin,
  deleteDiscountPoin,
} from "../../controllers/discountController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";

const router = express.Router();

router.get("/", authMiddleware, checkTokenBlacklist, getDiscountPoin);
router.get("/:id", authMiddleware, checkTokenBlacklist, getDiscountPoinById);
router.post("/", authMiddleware, checkTokenBlacklist, createDiscountPoin);
router.patch("/:id", authMiddleware, checkTokenBlacklist, updateDiscountPoin);
router.delete("/:id", authMiddleware, checkTokenBlacklist, deleteDiscountPoin);

export default router;
