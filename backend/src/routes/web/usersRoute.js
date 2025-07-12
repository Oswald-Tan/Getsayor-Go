import express from "express";
import {
  getUsers,
  getUserApprove,
  getUserById,
  getUserDetails,
  approveUser,
  approveUsers,
  getTotalUsers,
  createUser,
  updateUser,
  deleteUser,
} from "../../controllers/usersController.js";
import { verifyUser, adminOnly } from "../../middleware/authUser.js";

const router = express.Router();

router.get("/users", verifyUser, adminOnly, getUsers);
router.get("/users-approve", verifyUser, adminOnly, getUserApprove);
router.get("/users/:id/details", verifyUser, adminOnly, getUserDetails);
router.get("/user/:id", verifyUser, adminOnly, getUserById);
router.get("/total-users", verifyUser, getTotalUsers);
router.put("/approve", verifyUser, adminOnly, approveUser);
router.put("/approve-users", verifyUser, adminOnly, approveUsers);
router.post("/user", verifyUser, adminOnly, createUser);
router.patch("/user/:id", verifyUser, adminOnly, updateUser);

router.delete("/user/:id", verifyUser, adminOnly, deleteUser);

export default router;
