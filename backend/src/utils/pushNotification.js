import admin from "firebase-admin";
import path from "path";
import { fileURLToPath } from "url";
import { v4 as uuidv4 } from "uuid";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const serviceAccountPath = path.resolve(
  __dirname,
  "../config/push-notification-key.json"
);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath),
  });
}

//topup notification
export const sendTopupNotification = async (
  fcmToken,
  points,
  amount,
  firstName
) => {
  try {
    const uuid = uuidv4();
    const formattedAmount = new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      minimumFractionDigits: 2, // Pastikan 2 digit desimal
      maximumFractionDigits: 2,
    }).format(amount / 100); // BAGI DENGAN 100

    const message = {
      notification: {
        title: `Hai ${firstName}, Top Up Berhasil! 🎉`,
        body: `Anda berhasil top up ${points} poin senilai ${formattedAmount}.`,
      },
      data: {
        title: `Hai ${firstName}, Top Up Berhasil! 🎉`,
        body: `Anda berhasil top up ${points} poin senilai ${formattedAmount}.`,
        type: "topup_success",
        points: points.toString(),
        amount: amount.toString(),
        uuid: uuid,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channel_id: "topup_channel",
          sound: "default",
          tag: uuid,
        },
      },
      token: fcmToken,
    };

    return await admin.messaging().send(message);
  } catch (error) {
    console.error("Gagal mengirim notifikasi topup:", error);
    throw error;
  }
};

//pesanan cod notification
export const sendOrderCODNotification = async (
  fcmToken,
  orderId,
  totalAmount,
  firstName
) => {
  try {
    const uuid = uuidv4();
    const formattedAmount = new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
    }).format(totalAmount);

    const message = {
      notification: {
        title: `Hai ${firstName}, Pesanan COD Berhasil 🎉`,
        body: `Terima kasih telah berbelanja! Pesanan #${orderId} senilai ${formattedAmount} sudah kami terima.`,
      },
      data: {
        title: `Hai ${firstName}, Pesanan COD Berhasil 🎉`,
        body: `Terima kasih telah berbelanja! Pesanan #${orderId} senilai ${formattedAmount} sudah kami terima.`,
        type: "new_order",
        orderId: orderId.toString(),
        uuid: uuid,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channel_id: "order_channel",
          sound: "default",
          tag: uuid,
        },
      },
      token: fcmToken,
    };

    return await admin.messaging().send(message);
  } catch (error) {
    console.error("Gagal mengirim notifikasi:", error);
    throw error;
  }
};

//pesanan poin notification
export const sendOrderPOinNotification = async (
  fcmToken,
  orderId,
  totalAmount,
  firstName
) => {
  try {
    const uuid = uuidv4();
    const message = {
      notification: {
        title: `Hai ${firstName}, Pesanan POIN Berhasil 🎉`,
        body: `Terima kasih telah berbelanja! Pesanan #${orderId} senilai ${totalAmount} Poin sudah kami terima.`,
      },
      data: {
        title: `Hai ${firstName}, Pesanan POIN Berhasil 🎉`,
        body: `Terima kasih telah berbelanja! Pesanan #${orderId} senilai ${totalAmount} Poin sudah kami terima.`,
        type: "new_order",
        orderId: orderId.toString(),
        uuid: uuid,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channel_id: "order_channel",
          sound: "default",
          tag: uuid,
        },
      },
      token: fcmToken,
    };

    return await admin.messaging().send(message);
  } catch (error) {
    console.error("Gagal mengirim notifikasi:", error);
    throw error;
  }
};

export const sendStatusNotification = async (fcmToken, orderId, status) => {
  try {
    const uuid = uuidv4();
    const formattedStatus = status.charAt(0).toUpperCase() + status.slice(1);

    const message = {
      notification: {
        title: `Status Pesanan #${orderId} Diperbarui`,
        body: `Pesanan Anda sekarang dalam status: ${formattedStatus}`,
      },
      data: {
        title: `Status Pesanan #${orderId} Diperbarui`,
        body: `Pesanan Anda sekarang dalam status: ${formattedStatus}`,
        type: "status_update",
        orderId: orderId.toString(),
        uuid: uuid,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channel_id: "status_channel",
          sound: "default",
          tag: uuid,
        },
      },
      token: fcmToken,
    };

    return await admin.messaging().send(message);
  } catch (error) {
    console.error("Gagal mengirim notifikasi status:", error);
    throw error;
  }
};

export const isFcmTokenValid = async (fcmToken) => {
  try {
    // Coba kirim pesan test (dryRun: true tidak benar-benar mengirim)
    await admin.messaging().send(
      {
        token: fcmToken,
        data: { validation: "true" },
      },
      true // dryRun mode
    );
    return true;
  } catch (error) {
    console.error(`Token validation failed: ${fcmToken}`, error);
    return false;
  }
};
