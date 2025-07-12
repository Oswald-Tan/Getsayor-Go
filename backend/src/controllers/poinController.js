import Poin from "../models/poin.js";
import HargaPoin from "../models/hargaPoin.js";

// export const getPoins = async (req, res) => {
//   try {
//     const data = await Poin.findAll();
//     res.status(200).json(data);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

export const getPoins = async (req, res) => {
  try {
    const poins = await Poin.findAll({
      order: [['poin', 'ASC']]
    });
    res.status(200).json(poins);
  } catch (error) {
    console.error("Error in getPoins:", error);
    res.status(500).json({ message: error.message });
  }
};



export const getPoinById = async (req, res) => {
  try {
    const poin = await Poin.findOne({
      where: { id: req.params.id },
    });

    if (!poin) {
      return res.status(404).json({ message: "Poin not found" });
    }
    res.status(200).json(poin);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const createPoin = async (req, res) => {
  const { poin } = req.body;

  if (!poin) {
    return res.status(400).json({ message: "Poin is required" });
  }

  try {
    // Generate productId otomatis
    const productId = `points_${poin}`;
    
    // Cek apakah poin sudah ada
    const existingPoin = await Poin.findOne({ where: { poin } });
    if (existingPoin) {
      return res.status(400).json({ message: "Poin value already exists" });
    }

    // Buat poin baru dengan productId otomatis
    await Poin.create({ poin, productId });
    res.status(201).json({ message: "Poin created successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updatePoin = async (req, res) => {
  try {
    const { id } = req.params;
    const { discountPercentage } = req.body;

    // Validasi discountPercentage
    if (discountPercentage === undefined || discountPercentage === null) {
      return res.status(400).json({ message: "Discount percentage is required" });
    }

    const poin = await Poin.findOne({ where: { id } });
    if (!poin) {
      return res.status(404).json({ message: "Poin not found" });
    }

    let promoProductId = null;
    
    // Jika ada diskon, generate promoProductId
    if (discountPercentage > 0) {
      promoProductId = `points_${discountPercentage}_${poin.poin}`;
      
      // Validasi keunikan promoProductId
      const existingPromo = await Poin.findOne({ where: { promoProductId } });
      if (existingPromo && existingPromo.id !== parseInt(id)) {
        return res.status(400).json({ message: "Promo product ID already exists" });
      }
    }

    // Update data
    await Poin.update(
      { discountPercentage, promoProductId },
      { where: { id } }
    );

    res.status(200).json({ message: "Poin updated successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateDiscount = async (req, res) => {
  try {
    const { id, discountPercentage } = req.body;

    // Validasi input
    if (
      !id ||
      discountPercentage === undefined ||
      discountPercentage === null
    ) {
      return res
        .status(400)
        .json({ message: "Id and discountPercentage are required" });
    }

    // Validasi format discountPercentage
    if (
      isNaN(discountPercentage) ||
      discountPercentage < 0 ||
      discountPercentage > 100
    ) {
      return res
        .status(400)
        .json({
          message: "Discount percentage must be a number between 0 and 100",
        });
    }

    // Cari data poin berdasarkan ID
    const poin = await Poin.findOne({ where: { id } });

    if (!poin) {
      return res.status(404).json({ message: "Poin not found" });
    }

    // Hitung nilai diskon
    // const discountValue = Math.floor((poin.poin * discountPercentage) / 100);

    // Update data
    poin.discountPercentage = discountPercentage;
    // poin.discountValue = discountValue;
    await poin.save();

    // Kirimkan respon sukses
    res.status(200).json({ message: "Poin updated successfully", data: poin });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const deletePoin = async (req, res) => {
  try {
    const { id } = req.params;
    const poin = await Poin.findOne({ where: { id } });

    if (!poin) {
      return res.status(404).json({ message: "Poin not found" });
    }

    await Poin.destroy({ where: { id } });

    res.status(200).json({ message: "Poin deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
