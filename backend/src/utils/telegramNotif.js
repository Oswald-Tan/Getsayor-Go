import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

export const sendTelegramNotification = async (message) => {
  try {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    const chatIds = process.env.TELEGRAM_CHAT_IDS.split(",").map(id => id.trim());

    for (const chatId of chatIds) {
      await axios.post(`https://api.telegram.org/bot${token}/sendMessage`, {
        chat_id: chatId,
        text: message,
        parse_mode: "HTML"
      });
    }
  } catch (error) {
    console.error("Gagal mengirim notifikasi Telegram:", error.message);
  }
};
