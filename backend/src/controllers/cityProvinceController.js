import City from "../models/city.js";
import Province from "../models/province.js";

// Get all provinces and their cities
export const getProvinceAndCity = async (req, res) => {
  try {
    const provinces = await Province.findAll({
      include: {
        model: City,
        as: "cities",
      },
    });

    res.status(200).json({
      success: true,
      data: provinces,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching provinces and cities",
      error: error.message,
    });
  }
};

// Get all cities
export const getCity = async (req, res) => {
  try {
    const cities = await City.findAll({
      include: {
        model: Province,
        attributes: ["id", "name"], // Ambil data provinsi yang terkait
      },
    });

    res.status(200).json({
      success: true,
      data: cities,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching cities",
      error: error.message,
    });
  }
};


// Create province and cities
export const createProvinceAndCity = async (req, res) => {
  const { provinceName, cities } = req.body;

  try {
    // Create the province
    const province = await Province.create({ name: provinceName });

    // Create cities associated with the province
    const cityData = cities.map((cityName) => ({
      name: cityName,
      provinceId: province.id,
    }));
    await City.bulkCreate(cityData);

    res.status(201).json({
      success: true,
      message: "Province and cities created successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error creating province and cities",
      error: error.message,
    });
  }
};

// Delete province and its cities
export const deleteProvinceAndCities = async (req, res) => {
    const { id } = req.params;
  
    try {
      // Find the province by ID
      const province = await Province.findByPk(id, {
        include: {
          model: City,
          as: "cities",
        },
      });
  
      if (!province) {
        return res.status(404).json({
          success: false,
          message: "Province not found",
        });
      }
  
      // Delete all associated cities
      await City.destroy({
        where: {
          provinceId: id,
        },
      });
  
      // Delete the province
      await Province.destroy({
        where: {
          id,
        },
      });
  
      res.status(200).json({
        success: true,
        message: "Province and its cities deleted successfully",
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: "Error deleting province and cities",
        error: error.message,
      });
    }
  };