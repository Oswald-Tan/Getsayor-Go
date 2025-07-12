import express from "express";
import {
  getAllShippingRates,
  getShippingRateByCity,
  createShippingRate,
  updateShippingRate,
  deleteShippingRate,
  getShippingRateById,
} from "../../controllers/shippingRateController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get("/", verifyUser, adminOnly, getAllShippingRates);
router.get("/:cityId", verifyUser, adminOnly, getShippingRateByCity);
router.get("/price/:id", verifyUser, adminOnly, getShippingRateById);
router.post("/", verifyUser, adminOnly, createShippingRate);
router.put("/:id", verifyUser, adminOnly, updateShippingRate);
router.delete("/:id", verifyUser, adminOnly, deleteShippingRate);

export default router;
