import express from "express";
import { sendPushNotification } from "../../controllers/pushNotificationController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";

const router = express.Router();

router.post('/', sendPushNotification);

export default router;