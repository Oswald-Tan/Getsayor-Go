import HargaPoin from "../models/hargaPoin.js";

export const getHargaPoin = async (req, res) => {
  try {
    const data = await HargaPoin.findAll({
      attributes: ["id", "harga"],
    });
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getHargaPoinById = async (req, res) => {
  try {
    const harga = await HargaPoin.findOne({
      where: { id: req.params.id },
      attributes: ["id", "harga"],
    });

    if (!harga) {
      return res.status(404).json({ message: "Harga Poin not found" });
    }
    res.status(200).json(harga);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const createHargaPoin = async (req, res) => {
  const { harga } = req.body;

  if (!harga) {
    return res.status(400).json({ message: "Harga is required" });
  }

  //cek jika harga sudah ada maka tidak bisa di tambahkan lagi
  const existingHarga = await HargaPoin.findOne();
  if (existingHarga) {
    return res.status(400).json({ message: "Harga Poin already exists" });
  }

  try {
    await HargaPoin.create({ harga });
    res.status(201).json({ message: "Harga Poin created successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateHargaPoin = async (req, res) => {
  try {
    const hargaPoin = await HargaPoin.findOne();

    if (!hargaPoin) {
      return res.status(404).json({ message: "Harga Poin not found" });
    }

    const { harga } = req.body;

    await HargaPoin.update({ harga }, { where: { id: hargaPoin.id } });

    res.status(200).json({ message: "Harga Poin updated successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const deleteHargaPoin = async (req, res) => {
  try {
    const hargaPoin = await HargaPoin.findOne();

    if (!hargaPoin) {
      return res.status(404).json({ message: "Harga Poin not found" });
    }

    await HargaPoin.destroy({ where: { id: hargaPoin.id } });

    res.status(200).json({ message: "Harga Poin deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
