import express from "express";
import { buatPesananCOD, getPesanan, getPesananUpById, updatePesananStatus, deletePesananUp } from "../../controllers/pesananController.js";
import { verifyUser } from "../../middleware/authUser.js";

const router = express.Router();

router.get("/", verifyUser, getPesanan);
router.get("/:id", verifyUser, getPesananUpById);
router.post("/", verifyUser, buatPesananCOD);
router.patch("/:id", verifyUser, updatePesananStatus);
router.delete("/:id", verifyUser, deletePesananUp);

export default router;
