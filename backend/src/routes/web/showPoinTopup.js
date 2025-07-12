import express from "express";
import { getPoins, getPoinById, createPoin, updatePoin, deletePoin, updateDiscount } from "../../controllers/poinController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get('/', verifyUser, getPoins);
router.get('/:id', verifyUser, getPoinById);
router.post('/', verifyUser, createPoin);
router.post("/update-discount", verifyUser, updateDiscount);
router.patch('/:id', verifyUser, updatePoin);
router.delete('/:id', verifyUser, deletePoin);

export default router;