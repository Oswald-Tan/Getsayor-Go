import express from "express";
import {
  handleLogin,
  handleLogout,
  Me,
  updatePassword,
  requestResetOtp,
  verifyResetOtp,
  resetPassword,
  getResetOtpExpiry,
} from "../../controllers/authWebController.js";
import { verifyUser } from "../../middleware/authUser.js";

const router = express.Router();

router.post("/handle-login", handleLogin);
router.put("/update-pass/:id", verifyUser, updatePassword);
router.delete("/handle-logout", handleLogout);
router.post("/request-reset-otp", requestResetOtp);
router.post("/verify-reset-otp", verifyResetOtp);
router.post("/reset-password", resetPassword);
router.post("/get-reset-otp-expiry", getResetOtpExpiry);
router.get("/me", Me);

export default router;
