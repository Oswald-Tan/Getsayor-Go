import Cart from "../models/cart.js";
import Products from "../models/product.js";

//menambah item ke keranjang
export const addToCart = async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;

    // Cek jika produk sudah ada di keranjang
    const existingCartItem = await Cart.findOne({
      where: { userId, productId, status: "active" },
    });

    if (existingCartItem) {
      // Update jumlah jika produk sudah ada
      existingCartItem.quantity += quantity;

      const savedCartItem = await existingCartItem.save();
      return res
        .status(200)
        .json({ message: "Cart updated successfully", cart: savedCartItem });
    }

    // Tambahkan produk baru ke keranjang
    const newCartItem = await Cart.create({ userId, productId, quantity });
    res.status(201).json({ message: "Item added to cart", cart: newCartItem });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Failed to add item to cart", error: error.stack });
  }
};

// Mendapatkan data cart berdasarkan userId
export const getCartByUser = async (req, res) => {
  try {
    const { userId } = req.params;

    // Ambil semua item di cart untuk user tertentu
    const cartItems = await Cart.findAll({
      where: { userId, status: "active" },
      include: [
        {
          model: Products,
          as: "product",
          attributes: [
            "id",
            "nameProduk",
            "hargaPoin",
            "hargaRp",
            "jumlah",
            "satuan",
            "image",
          ],
        },
      ],
    });

    // Jika tidak ada item di cart
    if (cartItems.length === 0) {
      return res
        .status(200)
        .json({ cart: [], message: "No items in the cart" });
    }

    // Mengirimkan data cart
    return res.status(200).json({ cart: cartItems });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Failed to retrieve cart", error: error.stack });
  }
};

// Update berat item di keranjang
export const updateQuantityInCart = async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;

    // Validasi input
    if (!userId || !productId || quantity == null) {
      return res.status(400).json({ message: "Invalid input data" });
    }

    if (quantity <= 0) {
      return res
        .status(400)
        .json({ message: "Quantity harus lebih besar dari 0" });
    }

    // Cek jika produk ada di keranjang
    const existingCartItem = await Cart.findOne({
      where: { userId, productId, status: "active" },
      include: [{ model: Products, as: "product" }], // Include data produk untuk cek stok
    });

    if (!existingCartItem) {
      return res.status(404).json({ message: "Item not found in cart" });
    }

    // Cek stok produk
    const product = existingCartItem.product;
    if (quantity > product.stok) {
      return res.status(400).json({
        message: `Stok produk tidak mencukupi. Stok tersedia: ${product.stok}`,
      });
    }

    if (!existingCartItem) {
      return res.status(404).json({ message: "Item not found in cart" });
    }

    // Update quantity produk
    existingCartItem.quantity = quantity;
    const savedCartItem = await existingCartItem.save();

    return res.status(200).json({
      message: "Quantity produk berhasil diperbarui",
      cart: savedCartItem,
    });
  } catch (error) {
    console.error("Error in updateQuantityInCart:", error);
    return res.status(500).json({
      message: "Failed to update berat in cart",
      error: error.stack,
    });
  }
};

export const getItemCountInCart = async (req, res) => {
  try {
    const { userId } = req.params;

    //menghitung jumlah item dalam cart untuk user tertentu
    const itemCount = await Cart.count({
      where: { userId, status: "active" },
    });

    //mengirim jumlah item
    return res.status(200).json({ itemCount });
  } catch (error) {
    console.error("Error in getItemCountInCart:", error);
    return res.status(500).json({ message: "Failed to retrieve item count" });
  }
};

// Menghapus semua item dari keranjang berdasarkan userId
export const deleteCartItem = async (req, res) => {
  try {
    const { cartId } = req.params;
    const { userId } = req.body;

    // Validasi input
    if (!cartId || !userId) {
      return res
        .status(400)
        .json({ message: "Cart ID and User ID are required" });
    }

    // Cari item di keranjang berdasarkan cartId dan userId
    const cartItem = await Cart.findOne({
      where: { id: cartId, userId, status: "active" },
    });

    if (!cartItem) {
      return res
        .status(404)
        .json({
          message: "Cart item not found or does not belong to the user",
        });
    }

    // Hapus item dari keranjang
    await cartItem.destroy();

    return res
      .status(200)
      .json({ message: "Cart item deleted successfully", cartId });
  } catch (error) {
    console.error("Error in deleteCartItem:", error);
    return res
      .status(500)
      .json({ message: "Failed to delete cart item", error: error.stack });
  }
};
