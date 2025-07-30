import TopUpPoin from "../models/topUpPoin.js";
import User from "../models/user.js";
import DetailsUsers from "../models/details_users.js";
import UserPoints from "../models/userPoints.js";
import { v4 as uuidv4 } from "uuid";
import { Op } from "sequelize";
import db from "../config/database.js"
import { sendTopupNotification, isFcmTokenValid, } from "../utils/pushNotification.js";

export const getTopUp = async (req, res) => {
  const page = parseInt(req.query.page) || 0;
  const limit = parseInt(req.query.limit) || 10;
  const search = req.query.search || "";
  const offset = limit * page;

  try {
    const totalTopUp = await TopUpPoin.count({
      include: [
        {
          model: User,
          required: true,
          include: [
            {
              model: DetailsUsers,
              as: "userDetails",
              required: true,
              where: search ? { fullname: { [Op.substring]: search } } : {}, // Pencarian berdasarkan fullname
            },
          ],
        },
      ],
    });

    const totalRows = totalTopUp;
    const totalPage = Math.ceil(totalRows / limit);

    const data = await TopUpPoin.findAll({
      include: [
        {
          model: User,
          attributes: ["id", "email"],
          required: true,
          include: [
            {
              model: DetailsUsers,
              as: "userDetails",
              attributes: ["fullname"],
              required: true,
              where: search ? { fullname: { [Op.substring]: search } } : {}, // Pencarian berdasarkan fullname
            },
          ],
        },
      ],
      order: [["created_at", "DESC"]],
      offset: offset,
      limit: limit,
    });

    res.status(200).json({
      data,
      page,
      limit,
      totalPage,
      totalRows,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

//get total top up yang status pending
export const getTotalPendingTopUp = async (req, res) => {
  try {
    const totalTopUp = await TopUpPoin.count({
      where: { status: "pending" },
    });

    res.status(200).json({ totalTopUp });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getTotalCancelledTopUp = async (req, res) => {
  try {
    const totalTopUp = await TopUpPoin.count({
      where: { status: "cancelled" },
    });

    res.status(200).json({ totalTopUp });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getTotalApprovedTopUp = async (req, res) => {
  try {
    const totalTopUp = await TopUpPoin.count({
      where: { status: "success" },
    });

    res.status(200).json({ totalTopUp });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getTopUpById = async (req, res) => {
  const { id } = req.params; // Mendapatkan id dari parameter URL

  try {
    const topUp = await TopUpPoin.findOne({
      where: { id },
    });

    if (!topUp) {
      return res.status(404).json({ message: "Top Up not found" });
    }

    res.status(200).json(topUp);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getTopUpByUserId = async (req, res) => {
  try {
    const userId = req.user.id;

    const topUps = await TopUpPoin.findAll({
      where: { userId },
      include: {
        model: User,
        attributes: ["id", "email"],
      },
      order: [["created_at", "DESC"]],
    });

    if (topUps.length === 0) {
      return res.status(404).json({ message: "Belum ada Top Up" });
    }

    res.status(200).json(topUps);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getTotalTopUp = async (req, res) => {
  try {
    const { period } = req.params;

    let startDate;
    const endDate = new Date();
    endDate.setHours(23, 59, 59, 999); // Akhir hari

    // Menentukan startDate berdasarkan period
    switch (period) {
      case "weekly":
        startDate = new Date();
        startDate.setDate(startDate.getDate() - 7);
        // startDate.setDate(startDate.getDate() - startDate.getDay()); // Set ke Senin minggu ini
        // startDate.setHours(0, 0, 0, 0);
        break;
      case "monthly":
        startDate = new Date();
        startDate.setDate(1);
        break;
      case "yearly":
        startDate = new Date(new Date().getFullYear(), 0, 1);
        break;
      default:
        return res.status(400).json({ message: "Invalid period" });
    }

    startDate.setHours(0, 0, 0, 0); // Awal hari

    console.log("Start Date (Local):", startDate.toLocaleString());
    console.log("End Date (Local):", endDate.toLocaleString());

    // Query total top-up dengan status 'approved'
    const total = await TopUpPoin.sum("price", {
      where: {
        status: "success",
        created_at: {
          [Op.gte]: startDate,
          [Op.lte]: endDate,
        },
      },
    });

    console.log("Query Result:", total);

    res.json({ total: total || 0 });
  } catch (error) {
    console.error("Error fetching total top-up:", error);
    res.status(500).json({ message: "Server Error" });
  }
};

const generateUniqueTopupId = () => 
  `TP-${Date.now()}${Math.floor(Math.random() * 1000)}`;

export const postTopUp = async (req, res) => {
  const { points, price, date, paymentMethod, userId, purchaseId, invoiceNumber } = req.body;

  // Validate purchaseId format
  if (!purchaseId || typeof purchaseId !== 'string' || !/^[a-zA-Z0-9.-]+$/.test(purchaseId)) {
    return res.status(400).json({
      status: "error",
      message: "Invalid purchaseId format"
    });
  }

  // Validasi invoiceNumber
  if (!invoiceNumber || typeof invoiceNumber !== 'string') {
    return res.status(400).json({
      status: "error",
      message: "Invalid invoiceNumber format"
    });
  }

  // Mulai transaksi database
  const transaction = await db.transaction();

  try {
    // Check if user exists with lock
    const user = await User.findOne({
      where: { id: userId },
      include: [{
        model: DetailsUsers,
        as: "userDetails",
        attributes: ["fullname"],
        required: true,
      }],
      transaction,
      lock: transaction.LOCK.UPDATE
    });

    if (!user) {
      await transaction.rollback();
      return res.status(404).json({ 
        status: "error",
        message: "User not found" 
      });
    }

    // Cek duplikasi dengan LOCKING
    const existing = await TopUpPoin.findOne({
      where: { purchaseId },
      transaction,
      lock: transaction.LOCK.UPDATE
    });

    if (existing) {
      await transaction.commit();
      return res.status(200).json({
        status: "success",
        message: "Purchase already processed",
        topUpData: existing
      });
    }

    // Cek duplikasi invoiceNumber
    const existingInvoice = await TopUpPoin.findOne({
      where: { invoiceNumber },
      transaction,
      lock: transaction.LOCK.UPDATE
    });

    if (existingInvoice) {
      await transaction.rollback();
      return res.status(400).json({
        status: "error",
        message: "Invoice number already exists"
      });
    }


    // Cek duplikasi cepat dengan LOCKING (10 detik terakhir)
    const recentDuplicate = await TopUpPoin.findOne({
      where: {
        userId,
        created_at: { 
          [Op.gt]: new Date(Date.now() - 10000) // 10 detik
        }
      },
      transaction,
      lock: transaction.LOCK.UPDATE
    });

    if (recentDuplicate) {
      await transaction.commit();
      return res.status(200).json({
        status: "success",
        message: "Recent duplicate blocked",
        topUpData: recentDuplicate
      });
    }

    const topupId = generateUniqueTopupId();

    // Buat transaksi topup baru
    const topUpData = await TopUpPoin.create({
      userId,
      topupId,
      purchaseId,
      points,
      price,
      date,
      paymentMethod,
      status: "success",
      invoiceNumber,
    }, { transaction });

    // Update user points dengan locking
    let userPoints = await UserPoints.findOne({
      where: { userId },
      transaction,
      lock: transaction.LOCK.UPDATE
    });

    if (!userPoints) {
      userPoints = await UserPoints.create({
        userId,
        points: topUpData.points,
      }, { transaction });
    } else {
      userPoints.points = Number(userPoints.points) + Number(topUpData.points);
      await userPoints.save({ transaction });
    }

    // Commit semua perubahan
    await transaction.commit();

    const fcmToken = user.fcm_token;
    if (fcmToken) {
      try {
        const fullName = user.userDetails?.fullname || "";
        const firstNamePart = fullName.split(" ")[0] || "";
        const firstName = firstNamePart
          ? firstNamePart.charAt(0).toUpperCase() + 
            firstNamePart.slice(1).toLowerCase()
          : "Pelanggan";

        // Validasi token sebelum mengirim notifikasi
        const isValidToken = await isFcmTokenValid(fcmToken);

        if (isValidToken) {
          await sendTopupNotification(
            fcmToken,
            points,
            price,
            firstName
          );
        } else {
          console.log(`Token invalid, removing for user ${user.id}`);
          await User.update({ fcm_token: null }, { where: { id: user.id } });
        }
      } catch (error) {
        console.error("Error notifikasi topup:", error);
      }
    }

    return res.status(201).json({
      status: "success",
      message: "Top Up successful",
      topUpData,
      userPoints: userPoints.points,
    });
  } catch (error) {
    // Rollback transaksi jika ada error
    await transaction.rollback();
    console.error("Top-up error:", error);
    
    return res.status(500).json({
      status: "error",
      message: error.message || "Internal server error"
    });
  }
};

export const updateTopUp = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const topUp = await TopUpPoin.findOne({ where: { id } });

    if (!topUp) {
      return res.status(404).json({ message: "Top Up not found" });
    }

    if (status === "approved") {
      let userPoints = await UserPoints.findOne({
        where: { userId: topUp.userId },
      });

      //jika belum ada data user points maka buat baru
      if (!userPoints) {
        userPoints = await UserPoints.create({
          userId: topUp.userId,
          points: topUp.points,
        });
      } else {
        userPoints.points += topUp.points;
        await userPoints.save();
      }
    }

    topUp.status = status;
    await topUp.save();

    res.status(200).json({ message: "Top Up updated successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const deleteTopUp = async (req, res) => {
  try {
    const { id } = req.params;
    const topUp = await TopUpPoin.findOne({ where: { id } });

    if (!topUp) {
      return res.status(404).json({ message: "Top Up not found" });
    }

    await TopUpPoin.destroy({
      where: { id },
    });

    res.status(200).json({ message: "Top Up deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Controller untuk mengubah status top-up
export const updateTopUpStatus = async (req, res) => {
  const { status } = req.body;
  const { id } = req.params;

  try {
    // Cari transaksi berdasarkan ID
    const topUp = await TopUpPoin.findByPk(id);
    if (!topUp) {
      return res.status(404).json({ message: "Top-up transaction not found" });
    }

    // Periksa apakah status saat ini adalah "pending"
    if (topUp.status !== "pending") {
      return res.status(400).json({
        message: 'Status can only be updated from "pending" to "cancelled"',
      });
    }

    // Ubah status transaksi menjadi "cancelled"
    topUp.status = "cancelled";
    await topUp.save();

    return res
      .status(200)
      .json({ message: "Status updated successfully", topUp });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal server error" });
  }
};
