import express from "express";
import {
  registerUser,
  loginUser,
  getUserData,
  logoutUser,
  updateUser,
  requestResetOtp,
  verifyResetOtp,
  resetPassword,
  getResetOtpExpiry,
} from "../../controllers/authController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";
import User from "../../models/user.js";

const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/user", authMiddleware, checkTokenBlacklist, getUserData);
router.post("/logout", authMiddleware, logoutUser);
router.put("/:userId", updateUser);

router.post("/request-reset-otp", requestResetOtp);
router.post("/verify-reset-otp", verifyResetOtp);
router.post("/reset-password", resetPassword);
router.post("/get-reset-otp-expiry", getResetOtpExpiry);

router.patch('/update-fcm', 
  authMiddleware,
  checkTokenBlacklist,
  async (req, res) => {
    try {
      // Validasi tambahan
      if (!req.body.fcm_token || typeof req.body.fcm_token !== 'string') {
        return res.status(400).json({ 
          message: "Invalid FCM token format" 
        });
      }

      const user = await User.findByPk(req.user.id);
      if (!user) return res.status(404).json({ message: "User not found" });

      // Update token dan simpan ke database
      user.fcm_token = req.body.fcm_token.trim();
      await user.save();
      
      // Logging untuk debugging
      console.log(`Updated FCM token for user ${user.id}: ${user.fcm_token}`);
      
      res.status(200).json({ 
        message: "FCM token updated",
        fcm_token: user.fcm_token 
      });
    } catch (error) {
      console.error("Error updating FCM:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  }
);

export default router;
