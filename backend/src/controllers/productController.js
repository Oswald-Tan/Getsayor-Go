import Products from "../models/product.js";
import Setting from "../models/setting.js";
import { fileURLToPath } from "url";
import path from "path";
import fs from "fs";
import { Op } from "sequelize";
import db from "../config/database.js";

export const getProducts = async (req, res) => {
  try {
    const products = await Products.findAll();

    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getProductsApp = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const perPage = parseInt(req.query.per_page) || 10;
    const category = req.query.kategori;

    // BENAR: Gunakan operasi LIKE untuk case-insensitive
    const whereClause =
      category && category !== "All"
        ? {
            kategori: {
              [Op.like]: `%${category}%`,
            },
          }
        : {};

    const products = await Products.findAndCountAll({
      where: whereClause,
      limit: perPage,
      offset: (page - 1) * perPage,
      order: [["nameProduk", "ASC"]],
    });

    res.status(200).json({
      data: products.rows,
      meta: {
        total: products.count,
        page,
        perPage,
        totalPages: Math.ceil(products.count / perPage),
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Perbaikan query untuk MySQL
export const searchProductsApp = async (req, res) => {
  try {
    const { query, kategori } = req.query;
    const page = parseInt(req.query.page) || 1;
    const perPage = parseInt(req.query.per_page) || 10;
    const offset = (page - 1) * perPage;

    if (!query || query.trim() === "") {
      return res.status(200).json({
        data: [],
        meta: {
          total: 0,
          page,
          perPage,
          totalPages: 0,
        },
      });
    }

    // Build case-insensitive search condition
    const searchCondition = {
      [Op.or]: [
        {
          nameProduk: {
            [Op.like]: `%${query}%`,
          },
        },
        {
          deskripsi: {
            [Op.like]: `%${query}%`,
          },
        },
      ],
    };

    // Combine with category filter
    const whereClause = {
      [Op.and]: [
        ...(kategori && kategori !== "All" ? [{ kategori }] : []),
        searchCondition,
      ],
    };

    const { count, rows } = await Products.findAndCountAll({
      where: whereClause,
      limit: perPage,
      offset: offset,
      order: [["nameProduk", "ASC"]],
    });

    res.status(200).json({
      data: rows,
      meta: {
        total: count,
        page,
        perPage,
        totalPages: Math.ceil(count / perPage),
      },
    });
  } catch (error) {
    console.error("Search error:", error);
    res.status(500).json({
      error: "Internal server error",
      details: error.message,
    });
  }
};

export const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const product = await Products.findByPk(id);

    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.status(200).json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const createProduct = async (req, res) => {
  try {
    const { nameProduk, deskripsi, kategori, stok, hargaRp, jumlah, satuan } =
      req.body;

    //validasi input
    if (
      !nameProduk ||
      !deskripsi ||
      !kategori ||
      !stok ||
      !hargaRp ||
      !jumlah ||
      !satuan ||
      isNaN(hargaRp)
    ) {
      return res.status(400).json({ message: "Invalid input" });
    }

    //ambil nilai poin dari table settings
    const setting = await Setting.findOne({ where: { key: "hargaPoin" } });
    if (!setting) {
      return res.status(404).json({ message: "Harga Poin not found" });
    }

    const nilaiPoin = parseInt(setting.value, 10);

    //hitung hargaPoin berdasarkan hargaRp
    const hargaPoin = Math.round(hargaRp / nilaiPoin); //pembulatan ke integer

    //ambil image file gambar jika ada
    const image = req.file ? req.file.filename : null;

    //simpan produk ke database
    const product = await Products.create({
      nameProduk,
      deskripsi,
      kategori,
      stok,
      hargaPoin,
      hargaRp,
      jumlah,
      satuan,
      image,
    });

    res.status(201).json({ message: "Product created successfully", product });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { nameProduk, deskripsi, kategori, stok, hargaRp, jumlah, satuan } =
      req.body;

    // Ambil produk berdasarkan ID
    const product = await Products.findByPk(id);
    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    // Validasi hanya field yang ada di request body
    if (
      nameProduk ||
      deskripsi ||
      kategori ||
      stok ||
      hargaRp ||
      jumlah ||
      satuan
    ) {
      // Jika ada nama produk
      if (
        nameProduk &&
        (!nameProduk || nameProduk.length < 3 || nameProduk.length > 100)
      ) {
        return res
          .status(400)
          .json({ message: "nameProduk must be between 3 and 100 characters" });
      }

      // Jika ada deskripsi
      if (deskripsi && !deskripsi.trim()) {
        return res.status(400).json({ message: "Deskripsi is required" });
      }

      // Jika ada kategori
      if (kategori && !kategori.trim()) {
        return res.status(400).json({ message: "Kategori is required" });
      }

      // Jika ada stok dan harus valid angka
      if (stok && (isNaN(stok) || stok <= 0)) {
        return res
          .status(400)
          .json({ message: "Stok must be a positive number" });
      }

      // Validasi input jika ada hargaRp
      if (hargaRp && isNaN(hargaRp)) {
        return res.status(400).json({ message: "Invalid hargaRp input" });
      }

      // Jika ada jumlah dan harus valid angka
      if (jumlah && (isNaN(jumlah) || jumlah <= 0)) {
        return res
          .status(400)
          .json({ message: "Jumlah must be a positive number" });
      }

      // Jika ada satuan
      if (satuan && !satuan.trim()) {
        return res.status(400).json({ message: "Satuan is required" });
      }
    }

    // Ambil nilai poin dari table settings
    const setting = await Setting.findOne({ where: { key: "hargaPoin" } });
    if (!setting) {
      return res.status(404).json({ message: "Harga Poin not found" });
    }

    const nilaiPoin = parseInt(setting.value, 10);

    // Hitung hargaPoin jika hargaRp diupdate
    let hargaPoinCalculated = product.hargaPoin;
    if (hargaRp) {
      hargaPoinCalculated = Math.round(hargaRp / nilaiPoin);
    }

    // Ambil nama file gambar baru jika ada
    const image = req.file ? req.file.filename : product.image;

    // Update hanya properti yang disertakan dalam request
    product.nameProduk = nameProduk || product.nameProduk;
    product.deskripsi = deskripsi || product.deskripsi;
    product.kategori = kategori || product.kategori;
    product.stok = stok || product.stok;
    // Jika hargaRp diupdate
    if (hargaRp) {
      product.hargaRp = hargaRp;
      product.hargaPoin = hargaPoinCalculated;
    }
    product.jumlah = jumlah || product.jumlah;
    product.satuan = satuan || product.satuan;
    product.image = image;

    // Simpan perubahan
    await product.save();

    res.status(200).json({ message: "Product updated successfully", product });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const product = await Products.findByPk(id);

    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    // Hapus file gambar jika ada
    if (product.image) {
      const imagePath = path.join(__dirname, "../../uploads", product.image);

      // Cek apakah file ada sebelum menghapusnya
      fs.access(imagePath, fs.constants.F_OK, (err) => {
        if (!err) {
          fs.unlink(imagePath, (unlinkErr) => {
            if (unlinkErr) {
              console.error("Error deleting image:", unlinkErr);
            }
          });
        }
      });
    }

    // Hapus produk dari database
    await product.destroy();

    res.status(200).json({ message: "Product deleted successfully" });
  } catch (error) {
    console.error("Error in deleteProduct:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
