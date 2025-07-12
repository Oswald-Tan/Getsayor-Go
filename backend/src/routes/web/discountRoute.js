import express from "express";
import {
  getDiscountPoin,
  getDiscountPoinById,
  createDiscountPoin,
  updateDiscountPoin,
  deleteDiscountPoin,
} from "../../controllers/discountController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get("/", verifyUser, adminOnly, getDiscountPoin);
router.get("/:id", verifyUser, adminOnly, getDiscountPoinById);
router.post("/", verifyUser, adminOnly, createDiscountPoin);
router.patch("/:id", verifyUser, adminOnly, updateDiscountPoin);
router.delete("/:id", verifyUser, adminOnly, deleteDiscountPoin);

export default router;
