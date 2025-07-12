import express from "express";
import { getHargaPoin, getHargaPoinById, createHargaPoin, updateHargaPoin, deleteHargaPoin } from "../../controllers/hargaPoinController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get('/', verifyUser, adminOnly, getHargaPoin);
router.get('/:id', verifyUser, adminOnly, getHargaPoinById);
router.post('/', verifyUser, adminOnly, createHargaPoin);
router.patch('/:id', verifyUser, adminOnly, updateHargaPoin);
router.delete('/:id', verifyUser, adminOnly, deleteHargaPoin);

export default router;