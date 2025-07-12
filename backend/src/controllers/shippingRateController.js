import ShippingRate from "../models/shipping_rates.js";
import City from "../models/city.js";

// Get all shipping rates with city name
export const getAllShippingRates = async (req, res) => {
  try {
    const shippingRates = await ShippingRate.findAll({
      include: {
        model: City,
        attributes: ["id", "name"],
      },
    });

    res.status(200).json({
      success: true,
      data: shippingRates,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching shipping rates",
      error: error.message,
    });
  }
};

// Get shipping rate by ID
export const getShippingRateById = async (req, res) => {
    const { id } = req.params; // Mengambil id dari parameter URL
  
    try {
      const shippingRate = await ShippingRate.findOne({
        where: { id }, // Mencari berdasarkan id
        include: {
          model: City,
          attributes: ["id", "name"], // Menyertakan informasi kota
        },
      });
  
      if (!shippingRate) {
        return res.status(404).json({
          success: false,
          message: "Shipping rate not found",
        });
      }
  
      res.status(200).json({
        success: true,
        data: shippingRate,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: "Error fetching shipping rate",
        error: error.message,
      });
    }
  };
  

// Get shipping rate by city ID
export const getShippingRateByCity = async (req, res) => {
  const { cityId } = req.params;

  try {
    const shippingRate = await ShippingRate.findOne({
      where: { cityId },
      include: { model: City, attributes: ["id", "name"] },
    });

    if (!shippingRate) {
      return res.status(404).json({
        success: false,
        message: "Shipping rate not found for this city",
      });
    }

    res.status(200).json({
      success: true,
      data: shippingRate,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching shipping rate",
      error: error.message,
    });
  }
};

// Create shipping rate
export const createShippingRate = async (req, res) => {
  const { cityId, price } = req.body;

  try {
    const city = await City.findByPk(cityId);
    if (!city) {
      return res.status(404).json({
        success: false,
        message: "City not found",
      });
    }

    const shippingRate = await ShippingRate.create({ cityId, price });

    res.status(201).json({
      success: true,
      message: "Shipping rate created successfully",
      data: shippingRate,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error creating shipping rate",
      error: error.message,
    });
  }
};

// Update shipping rate
export const updateShippingRate = async (req, res) => {
  const { id } = req.params;
  const { price } = req.body;

  try {
    const shippingRate = await ShippingRate.findByPk(id);
    if (!shippingRate) {
      return res.status(404).json({
        success: false,
        message: "Shipping rate not found",
      });
    }

    shippingRate.price = price;
    await shippingRate.save();

    res.status(200).json({
      success: true,
      message: "Shipping rate updated successfully",
      data: shippingRate,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error updating shipping rate",
      error: error.message,
    });
  }
};

// Delete shipping rate
export const deleteShippingRate = async (req, res) => {
  const { id } = req.params;

  try {
    const shippingRate = await ShippingRate.findByPk(id);
    if (!shippingRate) {
      return res.status(404).json({
        success: false,
        message: "Shipping rate not found",
      });
    }

    await shippingRate.destroy();

    res.status(200).json({
      success: true,
      message: "Shipping rate deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error deleting shipping rate",
      error: error.message,
    });
  }
};
