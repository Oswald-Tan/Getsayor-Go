import Favorite from "../models/favorite.js";
import Products from "../models/product.js";

export const toggleFavorite = async (req, res) => {
  try {
    const { productId } = req.body;
    const userId = req.user.id;

    const existingFavorite = await Favorite.findOne({
      where: { userId, productId },
    });

    if (existingFavorite) {
      await existingFavorite.destroy();
      return res.json({ isFavorite: false, message: "Removed from favorites" });
    } else {
      const favorite = await Favorite.create({ userId, productId });
      return res.json({ isFavorite: true, message: "Added to favorites" });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getUserFavorites = async (req, res) => {
  try {
    const userId = req.user.id;

    const favorites = await Favorite.findAll({
      where: { userId },
      include: [
        {
          model: Products,
          attributes: [
            "id",
            "nameProduk",
            "deskripsi",
            "kategori",
            "stok",
            "hargaPoin",
            "hargaRp",
            "jumlah",
            "satuan",
            "image",
          ],
        },
      ],
    });

    // Transform to include isFavorite status
    const favoriteProducts = favorites.map((fav) => ({
      ...fav.Product.toJSON(),
      isFavorite: true, // Explicitly set to true
    }));

    res.json(favoriteProducts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

export const checkFavorite = async (req, res) => {
  try {
    const { productId } = req.params;
    const userId = req.user.id;

    const favorite = await Favorite.findOne({
      where: { userId, productId },
    });

    // Return boolean directly
    res.json({ isFavorite: !!favorite });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};
