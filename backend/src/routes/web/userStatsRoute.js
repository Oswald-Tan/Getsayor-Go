import express from "express";
import { getUserStats } from "../../controllers/userStatsController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

// Rute untuk mendapatkan statistik pengguna
router.get("/:id/stats", verifyUser, adminOnly, getUserStats);

export default router;
