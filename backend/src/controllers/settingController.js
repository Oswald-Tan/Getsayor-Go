import Products from "../models/product.js";
import Setting from "../models/setting.js";

export const getHargaPoin = async (req, res) => {
  try {
    const setting = await Setting.findOne({
      where: { key: "hargaPoin" },
    });

    if (!setting) {
      return res.status(404).json({ message: "Harga Poin not found" });
    }

    res.status(200).json({ hargaPoin: parseInt(setting.value, 10) });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const setHargaPoin = async (req, res) => {
  try {
    const { hargaPoin } = req.body;

    //validasi harga poin harus angka
    if (!hargaPoin || isNaN(hargaPoin)) {
      return res.status(400).json({ message: "Harga Poin must be a number" });
    }

    let setting = await Setting.findOne({
      where: { key: "hargaPoin" },
    });

    if (!setting) {
      setting = await Setting.create({
        key: "hargaPoin",
        value: hargaPoin.toString(),
      });
    } else {
      setting.value = hargaPoin.toString();
      await setting.save();
    }

    //perbarui hargaRp di table produk
    const products = await Products.findAll();
    const nilaiPoin = parseInt(hargaPoin, 10);

    for (const product of products) {
      product.hargaRp = product.hargaPoin * nilaiPoin;
      await product.save();
    }

    res.status(200).json({ message: "Harga Poin updated successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


