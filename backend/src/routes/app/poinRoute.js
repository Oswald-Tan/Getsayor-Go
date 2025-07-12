import express from "express";
import {
  getPoins,
  getPoinById,
  createPoin,
  updatePoin,
  updateDiscount,
  deletePoin,
} from "../../controllers/poinController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";

const router = express.Router();

router.get("/", authMiddleware, checkTokenBlacklist, getPoins);
router.get("/:id", authMiddleware, checkTokenBlacklist, getPoinById);
router.post("/", authMiddleware, checkTokenBlacklist, createPoin);
router.post("/update-discount", authMiddleware, checkTokenBlacklist, updateDiscount);
router.patch("/:id", authMiddleware, checkTokenBlacklist, updatePoin);
router.delete("/:id", authMiddleware, checkTokenBlacklist, deletePoin);

export default router;
