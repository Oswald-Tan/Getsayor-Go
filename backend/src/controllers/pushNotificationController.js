import admin from "firebase-admin";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const serviceAccountPath = path.resolve(__dirname, "../config/push-notification-key.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath),
  });
}

export const sendPushNotification = async (req, res, next) => {
  try {
    const { fcm_token } = req.body;

    if (!fcm_token) {
      return res.status(400).json({ message: "FCM token is required." });
    }

    const message = {
      notification: {
        title: "Test Notification",
        body: "Notification Message",
      },
      data: {
        orderId: "123456",
        orderDate: "2025-10-28",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channel_id: "high_importance_channel",
          priority: "high",
        }
      },
      token: fcm_token,
    };

    const response = await admin.messaging().send(message);

    return res.status(200).send({
      message: "Notification Sent",
      response: response,
    });
  } catch (error) {
    return res.status(500).send({
      message: "Notification Failed",
      error: error.message,
    });
  }
};