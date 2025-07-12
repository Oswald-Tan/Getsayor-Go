import Pesanan from "../models/pesanan.js";
import User from "../models/user.js";

export const getTotalPesananPending = async (req, res) => {
    try {
      const totalPesananPending = await Pesanan.count(
        {
          where: { status: "pending" },
        }
      ) 
  
      console.log(totalPesananPending);
  
      res.status(200).json({ totalPesananPending });
    } catch (error) {
      res.status(500).json({ message: "Error" }); 
    }
  };

  export const getTotalUserApproveFalse = async (req, res) => {
    try {
      // Menghitung jumlah user yang belum disetujui
      const totalUserApproveFalse = await User.count({
        where: {
          isApproved: false,
          role_id: 1,
        },
      });
  
      res.status(200).json({
        totalUserApproveFalse,
      });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };