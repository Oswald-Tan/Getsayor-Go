import express from "express";
import {
  getTotalPesananPending,
  getTotalUserApproveFalse,
} from "../../controllers/countController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get("/pesanan-pending", verifyUser, adminOnly, getTotalPesananPending);
router.get("/user-approve-false", verifyUser, adminOnly, getTotalUserApproveFalse);

export default router;
