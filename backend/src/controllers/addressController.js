import Address from "../models/address.js";
import City from "../models/city.js";
import ShippingRate from "../models/shipping_rates.js";
import db from "../config/database.js";

//tambah alamat baru

export const createAddress = async (req, res) => {
  const transaction = await db.transaction();
  try {
    const {
      user_id,
      recipient_name,
      phone_number,
      address_line_1,
      city,
      state,
      postal_code,
      isDefault,
    } = req.body;

    // Cek apakah user sudah memiliki alamat default
    const existingDefaultAddress = await Address.findOne({
      where: {
        user_id,
        is_default: true,
      },
      transaction,
    });

    let finalIsDefault = isDefault; // Nilai default dari request

    // Jika tidak ada alamat default yang sudah ada, atur alamat pertama sebagai default
    if (!existingDefaultAddress) {
      finalIsDefault = true;
    }

    // Jika isDefault true, update alamat lama menjadi is_default: false
    if (finalIsDefault) {
      await Address.update(
        { is_default: false },
        {
          where: {
            user_id,
            is_default: true,
          },
          transaction,
        }
      );
    }

    // Buat alamat baru dengan is_default sesuai aturan yang telah ditentukan
    const newAddress = await Address.create(
      {
        user_id,
        recipient_name,
        phone_number,
        address_line_1,
        city,
        state,
        postal_code,
        is_default: finalIsDefault,
      },
      { transaction }
    );

    await transaction.commit(); // Simpan perubahan

    res.status(201).json({
      message: "Address created successfully",
      data: newAddress,
    });
  } catch (error) {
    await transaction.rollback(); // Batalkan perubahan jika ada error
    res.status(500).json({
      message: "Error creating address",
      error: error.message,
    });
  }
};



// Edit alamat berdasarkan ID
export const updateAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id, recipient_name, phone_number, address_line_1, city, state, postal_code, isDefault } = req.body;

    // Cari alamat berdasarkan ID
    const addressToUpdate = await Address.findOne({ where: { id } });

    if (!addressToUpdate) {
      return res.status(404).json({ message: "Address not found" });
    }

    // Pastikan user_id yang mengirimkan request adalah pemilik alamat
    if (addressToUpdate.user_id !== user_id) {
      return res.status(403).json({ message: "You are not authorized to update this address" });
    }

    // Jika isDefault bernilai true dan alamat ini bukan default, ubah alamat lain menjadi non-default
    if (isDefault && !addressToUpdate.is_default) {
      await Address.update(
        { is_default: false },
        { where: { user_id: addressToUpdate.user_id, is_default: true } }
      );
    }

    // Perbarui alamat dengan data baru
    const updatedAddress = await addressToUpdate.update({
      recipient_name,
      phone_number,
      address_line_1,
      city,
      state,
      postal_code,
      is_default: !!isDefault, // Pastikan boolean
    });

    res.status(200).json({
      message: "Address updated successfully",
      data: updatedAddress,
    });
  } catch (error) {
    console.error("Error updating address:", error.message);
    res.status(500).json({ message: "Error updating address", error: error.message });
  }
};


// Mendapatkan alamat berdasarkan ID
export const getAddressById = async (req, res) => {
  try {
    const { id } = req.params;

    // Cari alamat berdasarkan ID
    const address = await Address.findOne({ where: { id } });

    if (!address) {
      return res.status(404).json({ message: "Address not found" });
    }

    res.status(200).json({
      message: "Address retrieved successfully",
      data: address,
    });
  } catch (error) {
    res.status(500).json({
      message: "Error retrieving address",
      error: error.message,
    });
  }
};



//mendapatkan semua alamat milik user tertentu
export const getUserAddresses = async (req, res) => {
  try {
    const { user_id } = req.params;

    const addresses = await Address.findAll({
      where: { user_id },
    });

    res
      .status(200)
      .json({ message: "Addresses retrieved successfully", data: addresses });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error retrieving addresses", error: error.message });
  }
};

// Mendapatkan alamat default untuk user tertentu
export const getDefaultAddress = async (req, res) => {
  try {
    const { user_id } = req.params;

    // Cari alamat default untuk user
    const defaultAddress = await Address.findOne({
      where: {
        user_id,
        is_default: true,
      },
    });

    if (!defaultAddress) {
      return res.status(404).json({ message: "Default address not found" });
    }

    // Cari City berdasarkan nama kota dari defaultAddress
    const city = await City.findOne({
      where: { name: defaultAddress.city },
    });

    // Jika city tidak ditemukan, langsung return tanpa shippingRate
    if (!city) {
      return res.status(200).json({
        message: "Default address retrieved successfully",
        defaultAddress,
        shippingRate: null,
      });
    }

    // Cari ShippingRate berdasarkan cityId
    const shippingRate = await ShippingRate.findOne({
      where: { cityId: city.id },
      include: {
        model: City,
        attributes: ["id", "name"],
      },
    });

    res.status(200).json({
      message: "Default address retrieved successfully",
      defaultAddress,
      shippingRate: shippingRate
        ? {
            id: shippingRate.id,
            cityId: shippingRate.cityId,
            price: shippingRate.price,
            city: shippingRate.City,
          }
        : null,
    });
  } catch (error) {
    res.status(500).json({
      message: "Error retrieving default address",
      error: error.message,
    });
  }
};




//hapus alamat berdasarkan ID
export const deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;

    // Cari alamat yang ingin dihapus berdasarkan ID
    const addressToDelete = await Address.findOne({ where: { id } });

    if (!addressToDelete) {
      return res.status(404).json({ message: "Address not found" });
    }

    // Jika alamat adalah alamat default, maka tidak bisa dihapus
    if (addressToDelete.is_default) {
      return res.status(400).json({
        message:
          "Default address cannot be deleted. Please update the default address first.",
      });
    }

    // Jika validasi berhasil, lanjutkan untuk menghapus alamat
    const deleted = await Address.destroy({ where: { id } });

    if (deleted) {
      res.status(200).json({ message: "Address deleted successfully" });
    } else {
      res.status(404).json({ message: "Address not found" });
    }
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error deleting address", error: error.message });
  }
};
