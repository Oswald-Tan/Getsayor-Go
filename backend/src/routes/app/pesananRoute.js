import express from "express";
import { buatPesananCOD, buatPesananCODCart, buatPesananPoin, buatPesananPoinCart, getPesanan, getPesananByUser, getPesananByUserDelivered } from "../../controllers/pesananController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";
import Pesanan from "../../models/pesanan.js";
import OrderItem from "../../models/orderItem.js";
import Products from "../../models/product.js";
import User from "../../models/user.js";
import DetailsUsers from "../../models/details_users.js";

const router = express.Router();

router.get("/", authMiddleware, checkTokenBlacklist, getPesanan);
router.get("/user/:userId", getPesananByUser);
router.get("/user-delivered/:userId", getPesananByUserDelivered);
router.get('/check', async (req, res) => {
    try {
      const { idempotencyKey } = req.query;
      const order = await Pesanan.findOne({
        where: { idempotencyKey },
        include: [
          {
            model: OrderItem,
            as: "orderItems",
            include: [
              {
                model: Products,
                as: "produk",
                attributes: ["id", "nameProduk", "image"],
              },
            ] 
          },
          {
            model: User,
            as: "user",
            include: [
              {
                model: DetailsUsers,
                as: "userDetails",
                attributes: ["fullname"],
              },
            ] 
          }
        ]
      });
  
      if (!order) {
        return res.status(404).json({ message: "Order not found" });
      }
      
      res.status(200).json(order);
      console.log(order);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  });
router.post("/cod", authMiddleware, checkTokenBlacklist, buatPesananCOD);
router.post("/cod-cart", authMiddleware, checkTokenBlacklist, buatPesananCODCart);
router.post("/poin", authMiddleware, checkTokenBlacklist, buatPesananPoin);
router.post("/poin-cart", authMiddleware, checkTokenBlacklist, buatPesananPoinCart);

export default router;
