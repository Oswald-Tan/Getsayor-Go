import express from "express";
import {
  getTopUp,
  postTopUp,
  getTopUpByUserId
} from "../../controllers/topUpPoinFromWebController.js";
import { verifyUser } from "../../middleware/authUser.js";

const router = express.Router();

router.post("/", verifyUser, postTopUp);
router.get("/", verifyUser, getTopUpByUserId);

export default router;
