import express from "express";
import { getHargaPoin, setHargaPoin } from "../../controllers/settingController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get('/harga-poin', verifyUser, adminOnly, getHargaPoin);
router.post('/harga-poin', verifyUser, adminOnly, setHargaPoin);

export default router;