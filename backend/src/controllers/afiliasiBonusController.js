import AfiliasiBonus from "../models/afiliasiBonus.js";
import moment from "moment";
import TotalBonus from "../models/totalBonus.js";

export const claimBonus = async (req, res) => {
  const { bonusId } = req.body;

  try {
    // Cari bonus dengan status 'pending'
    const bonus = await AfiliasiBonus.findOne({
      where: { id: bonusId, status: "pending" },
    });

    if (!bonus) {
      return res
        .status(404)
        .json({ message: "Bonus not found or already claimed." });
    }

    // Periksa apakah bonus sudah kedaluwarsa
    const isExpired = moment().isAfter(moment(bonus.expiryDate));
    if (isExpired) {
      bonus.set({ status: "expired" });
      await bonus.save();
      return res
        .status(400)
        .json({ message: "Bonus has expired and cannot be claimed." });
    }

    // Ambil nilai bonusAmount yang diklaim
    const bonusAmount = bonus.bonusAmount;

    // Cari entri TotalBonus untuk user yang bersangkutan
    let totalBonus = await TotalBonus.findOne({
      where: { userId: bonus.userId },
    });

    if (!totalBonus) {
      // Jika tidak ada, buat entri baru dengan bonusAmount pertama kali
      totalBonus = await TotalBonus.create({
        userId: bonus.userId,
        totalBonus: bonusAmount,
      });
    } else {
      // Cek apakah totalBonus sudah mencapai 500000
      if (totalBonus.totalBonus + bonusAmount > 500000) {
        return res
          .status(400)
          .json({ message: "Total bonus already reached 500,000." });
      }

      // Jika belum mencapai 500000, tambahkan bonusAmount ke totalBonus
      totalBonus.totalBonus += bonusAmount;
      await totalBonus.save();
    }

    // Update status bonus menjadi 'claimed'
    bonus.set({ status: "claimed", claimedAt: moment().toDate() });
    await bonus.save(); // Simpan perubahan ke database

    // Kirimkan respon
    res.status(200).json({
      message: "Bonus claimed and total bonus updated successfully.",
      bonus,
      totalBonus,
    });
  } catch (error) {
    console.error("Error claiming bonus:", error);
    res.status(500).json({ message: error.message });
  }
};



// Get total bonus claimed
export const getTotalBonus = async (req, res) => {
  const { userId } = req.params;

  try {
    const totalBonus = await AfiliasiBonus.sum("bonusAmount", {
      where: { userId: userId, status: "claimed" },
    });

    res.status(200).json({
      message: "Total bonus retrieved successfully.",
      totalBonus: totalBonus || 0,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get pending bonuses for a user
export const getPendingBonus = async (req, res) => {
  const { userId } = req.params;

  try {
    const pendingBonus = await AfiliasiBonus.findAll({
      where: { userId: userId, status: "pending" },
      attributes: ["id", "bonusAmount", "bonusReceivedAt", "expiryDate", "status"],
      order: [["expiryDate", "ASC"]],
    });

    if (pendingBonus.length === 0) {
      return res.status(200).json({
        message: "No pending bonus to claim.",
        pendingBonus: [],
      });
    }

    res.status(200).json({
      message: "Pending bonuses retrieved successfully.",
      pendingBonus,
    });
  } catch (error) {
    console.error("Error fetching pending bonuses:", error);
    res.status(500).json({ message: "An error occurred while fetching bonuses." });
  }
};

// Get expired bonuses for a user
export const getExpiredBonus = async (req, res) => {
  const { userId } = req.params;

  try {
    const expiredBonus = await AfiliasiBonus.findAll({
      where: { userId: userId, status: "expired" },
      attributes: ["id", "bonusAmount", "bonusReceivedAt", "expiryDate", "status"],
      order: [["expiryDate", "ASC"]],
    });

    if (expiredBonus.length === 0) {
      return res.status(200).json({
        message: "No expired bonus to claim.",
        expiredBonus: [],
      });
    }

    res.status(200).json({
      message: "Expired bonuses retrieved successfully.",
      expiredBonus,
    });
  } catch (error) {
    console.error("Error fetching expired bonuses:", error);
    res.status(500).json({ message: "An error occurred while fetching bonuses." });
  }
};