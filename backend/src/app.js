import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import session from "express-session";
import SequelizeStore from "connect-session-sequelize";
import { Server } from "socket.io";
import http from "http";
import db from "./config/database.js";
import path from "path";
import { fileURLToPath } from "url";
import cron from "node-cron";
import moment from "moment";
import { Op } from "sequelize";
import AfiliasiBonus from "./models/afiliasiBonus.js";
import crypto from "crypto";
import fs from "fs";

// Mendapatkan direktori saat ini
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();

//app
import Auth from "./routes/app/authRoute.js";
import PoinApp from "./routes/app/poinRoute.js";
import HargaApp from "./routes/app/hargaPoinRoute.js";
import DiscountApp from "./routes/app/discountRoute.js";
import TopUpPoinApp from "./routes/app/topUpPoinRoute.js";
import PesananApp from "./routes/app/pesananRoute.js";
import ProductsApp from "./routes/app/productRoute.js";
import CartApp from "./routes/app/cartRoute.js";
import AfiliasiBonusApp from "./routes/app/afiliasiBonusRoute.js";
import SettingApp from "./routes/app/settingRoute.js";
import Address from "./routes/app/addressRoute.js";
import BankAccount from "./routes/app/bankAccountRoute.js";
import PushNotification from "./routes/app/pushNotificationRoute.js";
import Favorite from "./routes/app/favoriteRoutes.js";

//web
import AuthWeb from "./routes/web/authWebRoute.js";
import AuthTopup from "./routes/web/authTopupRoute.js";
import User from "./routes/web/usersRoute.js";
import Products from "./routes/web/productRoute.js";
import Harga from "./routes/web/hargaPoinRoute.js";
import Poin from "./routes/web/poinRoute.js";
import ShowPoinTopup from "./routes/web/showPoinTopup.js";
import Discount from "./routes/web/discountRoute.js";
import TopUpPoin from "./routes/web/topUpPoinRoute.js";
import Pesanan from "./routes/web/pesananRoute.js";
import Setting from "./routes/web/settingRoute.js";
import UserStats from "./routes/web/userStatsRoute.js";
import Count from "./routes/web/countRoute.js";
import ProvincesCities from "./routes/web/cityProvinceRoute.js";
import ShippingRate from "./routes/web/shippingRatesRoute.js";
import TopupFromWeb from "./routes/web/topupFromWebRoute.js";
import UserPoints from "./routes/web/usersPointsRoute.js";

const app = express();
const httpServer = http.createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: ["http://localhost:5173", "http://192.168.105.53:8080"], 
    methods: ["GET", "POST"],
    credentials: true,
  }
});

const sessionStore = SequelizeStore(session.Store);

const store = new sessionStore({
  db: db,
});

// app.use(
//   session({
//     secret: process.env.SESS_SECRET,
//     resave: false,
//     saveUninitialized: true,
//     store: store, //simpan session ke database
//     cookie: {
//       secure: "auto",
//     },
//   })
// );

const sessionMiddleware = session({
  secret: process.env.SESS_SECRET,
  resave: false,
  saveUninitialized: true,
  store: store, // Simpan session ke database
  cookie: {
    secure: "auto",
  },
});

app.use(express.json());

const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(",") || [];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    credentials: true,
  })
);

app.use(
  "/uploads",
  express.static(path.join(__dirname, "../uploads"), {
    setHeaders: (res, path) => {
      // Cache-Control
      res.setHeader("Cache-Control", "public, max-age=31536000, immutable");
    
      // ETag secara sinkron
      try {
        const fileBuffer = fs.readFileSync(path);
        const hash = crypto.createHash("md5").update(fileBuffer).digest("hex");
        res.setHeader("ETag", hash);
      } catch (error) {
        console.error("Error generating ETag:", error);
      }
    }
    
  })
);

app.get("/api/v1/hello-world", (req, res) => {
  res.status(200).json({ message: "Hello, World!" });
});

//app
app.use("/api/v1/auth", Auth);
app.use("/api/v1/poin-app", PoinApp);
app.use("/api/v1/harga-poin-app", HargaApp);
app.use("/api/v1/discount-app", DiscountApp);
app.use("/api/v1/topup-app", TopUpPoinApp);
app.use("/api/v1/pesanan-app", PesananApp);
app.use("/api/v1/products-app", ProductsApp);
app.use("/api/v1/cart-app", CartApp);
app.use("/api/v1/afiliasi-bonus-app", AfiliasiBonusApp);
app.use("/api/v1/settings-app", SettingApp);
app.use("/api/v1/addresses", Address);
app.use("/api/v1/bank-account", BankAccount);
app.use("/api/v1/push-notification", PushNotification);
app.use("/api/v1/favorites", Favorite);

//web
// Terapkan session hanya untuk rute web
app.use("/api/v1/auth-web", sessionMiddleware, AuthWeb);
app.use("/api/v1/auth-topup", sessionMiddleware, AuthTopup);
app.use("/api/v1/users", sessionMiddleware, User);
app.use("/api/v1/products", sessionMiddleware, Products);
app.use("/api/v1/harga", sessionMiddleware, Harga);
app.use("/api/v1/poin", sessionMiddleware, Poin);
app.use("/api/v1/show-poin", sessionMiddleware, ShowPoinTopup);
app.use("/api/v1/discount", sessionMiddleware, Discount);
app.use("/api/v1/topup", sessionMiddleware, TopUpPoin);
app.use("/api/v1/pesanan", sessionMiddleware, Pesanan);
app.use("/api/v1/settings", sessionMiddleware, Setting);
app.use("/api/v1/user-stats", sessionMiddleware, UserStats);
app.use("/api/v1/count", sessionMiddleware, Count);
app.use("/api/v1/provinces-cities", sessionMiddleware, ProvincesCities);
app.use("/api/v1/shipping-rates", sessionMiddleware, ShippingRate);
app.use("/api/v1/topup-from-web", sessionMiddleware, TopupFromWeb);
app.use("/api/v1/user-points", sessionMiddleware, UserPoints);

//jadwal cron job untuk memeriksa bonus yang sudah expired
cron.schedule("0 0 * * *", async () => {
  console.log("Running cron job to update expired bonuses...");

  try {
    const currentDate = moment().toDate(); //tanggal saat ini

    //update status menjadi expired jika melewati expiryDate
    const result = await AfiliasiBonus.update(
      { status: "expired" }, //set status ke expired
      {
        where: {
          status: "pending",
          expiryDate: {
            [Op.lt]: currentDate,
          },
        },
      }
    );

    console.log(`result ${result[0]} bonuses to status "expired".`);
  } catch (error) {
    console.error("Error updating expired bonuses:", error);
  }
});

// // Socket.IO middleware for session
// io.use((socket, next) => {
//   sessionMiddleware(socket.request, {}, (err) => {
//     if (err) return next(err);
//     console.log(socket.request.session); // Periksa apakah sesi tersedia di sini
//     next();
//   });
// });

// // Handle socket connections
// io.on("connection", (socket) => {
//   console.log("New client connected", socket.id);
//   socket.on("disconnect", () => {
//     console.log("Client disconnected", socket.id);
//   });
// });

// // Save io instance to app
// app.set("socketio", io);


const PORT = process.env.PORT;
httpServer.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
