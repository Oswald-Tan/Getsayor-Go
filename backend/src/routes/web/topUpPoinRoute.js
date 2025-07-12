import express from "express";
import {
  getTopUp,
  deleteTopUp,
  getTopUpById,
  getTotalApprovedTopUp,
  getTotalPendingTopUp,
  getTotalCancelledTopUp,
  getTotalTopUp,
  updateTopUp,
} from "../../controllers/topUpPoinController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get("/", verifyUser, adminOnly, getTopUp);
router.get("/approved", verifyUser, adminOnly, getTotalApprovedTopUp);
router.get("/pending", verifyUser, adminOnly, getTotalPendingTopUp);
router.get("/cancelled", verifyUser, adminOnly, getTotalCancelledTopUp);
router.get("/:id", verifyUser, adminOnly, getTopUpById);
router.get("/total/:period", verifyUser, adminOnly, getTotalTopUp);
router.patch("/:id", verifyUser, adminOnly, updateTopUp);
router.delete("/:id", verifyUser, adminOnly, deleteTopUp);

export default router;
