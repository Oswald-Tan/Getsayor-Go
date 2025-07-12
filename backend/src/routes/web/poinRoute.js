import express from "express";
import { getPoins, getPoinById, createPoin, updatePoin, deletePoin, updateDiscount } from "../../controllers/poinController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get('/', verifyUser, adminOnly, getPoins);
router.get('/:id', verifyUser, adminOnly, getPoinById);
router.post('/', verifyUser, adminOnly, createPoin);
router.post("/update-discount", verifyUser, adminOnly, updateDiscount);
router.patch('/:id', verifyUser, adminOnly, updatePoin);
router.delete('/:id', verifyUser, adminOnly, deletePoin);

export default router;