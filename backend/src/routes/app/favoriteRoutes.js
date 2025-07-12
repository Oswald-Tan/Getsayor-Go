import express from "express";
import {
  toggleFavorite, getUserFavorites, checkFavorite
} from "../../controllers/favoriteController.js";
import authMiddleware from "../../middleware/authMiddleware.js";
import { checkTokenBlacklist } from "../../middleware/checkTokenBlacklist.js";

const router = express.Router();

router.get("/", authMiddleware, checkTokenBlacklist, getUserFavorites);
router.get("/:productId", authMiddleware, checkTokenBlacklist, checkFavorite);
router.post("/toggle", authMiddleware, checkTokenBlacklist, toggleFavorite);

export default router;
