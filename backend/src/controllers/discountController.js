import Discount from "../models/discountPoin.js";
import Poin from "../models/poin.js";

export const getDiscountPoin = async (req, res) => {
  try {
    const data = await Discount.findAll({
      attributes: ["id", "percentage", "poinId"],
      include: [
        {
          model: Poin,
          as: "poin",
          attributes: ["poin"],
        },
      ],
    });

    const discounts = data.map((discount) => ({
      id: discount.id,
      percentage: discount.percentage,
      poin: discount.poin.poin,
    }));
    res.status(200).json(discounts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getDiscountPoinById = async (req, res) => {
  try {
    const discount = await Discount.findOne({
      where: { id: req.params.id },
      attributes: ["id", "percentage", "poinId"],
      include: [
        {
          model: Poin,
          as: "poin",
          attributes: ["poin"],
        },
      ],
    });

    if (!discount) {
      return res.status(404).json({ message: "Discount not found" });
    }

    res.status(200).json({
      id: discount.id,
      percentage: discount.percentage,
      poinId: discount.poinId,
      poin: discount.poin.poin,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const createDiscountPoin = async (req, res) => {
  const { percentage, poinId } = req.body;

  try {
    //validasi input
    if (!percentage || !poinId) {
      return res
        .status(400)
        .json({ message: "Percentage and poinId are required" });
    }

    //terapkan discount
    const result = await Discount.create({ percentage, poinId });

    res
      .status(201)
      .json({ message: "Discount created successfully", data: result });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateDiscountPoin = async (req, res) => {
  const { id } = req.params;
  const { percentage, poinId } = req.body;

  try {
    //validasi input
    if (!percentage || !poinId) {
      return res
        .status(400)
        .json({ message: "Percentage and poinId are required" });
    }

    //cari dicount berdasarkan id
    const discount = await Discount.findByPk(id);

    if (!discount) {
      return res.status(404).json({ message: "Discount not found" });
    }

    //perbarui data discount
    discount.percentage = percentage;
    discount.poinId = poinId;

    await discount.save();

    res.status(200).json({ message: "Discount updated successfully", data: discount });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const deleteDiscountPoin = async (req, res) => {
  const { id } = req.params;

  try {
    const discount = await Discount.findByPk(id);

    if (!discount) {
      return res.status(404).json({ message: "Discount not found" });
    }

    await discount.destroy();

    res.status(200).json({ message: "Discount deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

