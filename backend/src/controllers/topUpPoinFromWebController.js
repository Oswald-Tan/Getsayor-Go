import TopUpPoin from "../models/topUpPoin.js";
import User from "../models/user.js";
import DetailsUsers from "../models/details_users.js";
import UserPoints from "../models/userPoints.js";
import { Op, Sequelize } from "sequelize";

export const getTopUp = async (req, res) => {
  const page = parseInt(req.query.page) || 0;
  const limit = parseInt(req.query.limit) || 10;
  const search = req.query.search || "";
  const status = req.query.status || "all";
  const offset = limit * page;

  try {
    // Buat kondisi where untuk status
    const topUpWhere = {};
    if (status !== "all") {
      topUpWhere.status = status;
    }

    const totalTopUp = await TopUpPoin.count({
      where: topUpWhere,
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
      where: topUpWhere,
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
      where: { status: "approved" },
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
    const page = parseInt(req.query.page) || 0;
    const limit = parseInt(req.query.limit) || 10;
    const offset = limit * page;
    const status = req.query.status || "all";
    const userId = req.userId;

    const topUpWhere = { userId };
  
    if (status !== "all") {
      topUpWhere.status = status;
    }

    const totalTopUp = await TopUpPoin.count({
      where: topUpWhere,
      include: [
        {
          model: User,
          required: true,
          include: [
            {
              model: DetailsUsers,
              as: "userDetails",
              required: true,
            },
          ],
        },
      ],
    });

    const totalRows = totalTopUp;
    const totalPage = Math.ceil(totalRows / limit);

    const topUps = await TopUpPoin.findAll({
      where: topUpWhere,
      include: {
        model: User,
        attributes: ["id", "email"],
        include: [
          {
            model: DetailsUsers,
            as: "userDetails",
            attributes: ["fullname"],
            required: true,
          },
        ],
      },
      order: [["created_at", "DESC"]],
      offset: offset,
      limit: limit,
    });

    if (topUps.length === 0) {
      return res.status(404).json({ message: "Belum ada Top Up" });
    }

    res.status(200).json({
      data: topUps,
      page,
      limit,
      totalPage,
      totalRows,
    });
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
        status: "approved",
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

export const postTopUp = async (req, res) => {
  // 1. Dapatkan data dari request body
  const { points, price, bankName } = req.body;

  // 2. Dapatkan user ID dari middleware auth
  const userId = req.userId;

  try {
    // 3. Cek user yang melakukan top-up
    const user = await User.findOne({
      where: { id: userId },
      include: {
        model: DetailsUsers,
        as: "userDetails",
        attributes: ["fullname"],
        required: true,
      },
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // 4. Buat record top-up baru
    const topUpData = await TopUpPoin.create({
      userId,
      points,
      price,
      date: new Date(),
      bankName,
      status: "pending",
    });

    // 5. Kirim notifikasi real-time via Socket.io
    // const io = req.app.get("socketio");
    // io.emit("newTopUp", {
    //   userId,
    //   fullname: user.userDetails.fullname,
    //   points,
    //   price,
    //   date: new Date(),
    //   bankName,
    //   status: "pending",
    // });

    // 6. Response ke client
    return res.status(201).json({
      message: "Top Up successful",
      transactionId: topUpData.id,
      points: topUpData.points,
      price: topUpData.price,
      status: topUpData.status,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
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
