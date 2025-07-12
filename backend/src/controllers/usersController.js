import User from "../models/user.js";
import Role from "../models/role.js";
import bcrypt from "bcrypt";
import { Op } from "sequelize";
import DetailsUsers from "../models/details_users.js";

export const getUsers = async (req, res) => {
  const page = parseInt(req.query.page) || 0;
  const limit = parseInt(req.query.limit) || 10;
  const search = req.query.search || "";
  const offset = limit * page;

  try {
    // Hitung total user berdasarkan pencarian fullname
    const totalUser = await User.count({
      include: {
        model: DetailsUsers,
        as: "userDetails",
        attributes: ["fullname"],
        where: search ? { fullname: { [Op.substring]: search } } : {},
        required: true,
      },
    });

    const totalRows = totalUser;
    const totalPage = Math.ceil(totalRows / limit);

    // Ambil data user dengan fullname dari DetailUsers
    const users = await User.findAll({
      include: [
        {
          model: DetailsUsers,
          as: "userDetails",
          attributes: ["fullname"], 
          required: true,
          where: search ? { fullname: { [Op.substring]: search } } : {},
        },
        {
          model: Role,
          as: "userRole",
          attributes: ["role_name"],
        },
      ],
      attributes: ["id", "email", "role_id"],
      order: [["userDetails", "fullname", "ASC"]],
      offset: offset,
      limit: limit,
    });

    // Mapping data untuk response
    const data = users.map((user) => ({
      id: user.id,
      fullname: user.userDetails ? user.userDetails.fullname : null,
      email: user.email,
      role: user.userRole.role_name,
    }));

    res.status(200).json({
      data,
      page,
      limit,
      totalPage,
      totalRows,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


export const getUserApprove = async (req, res) => {
  const page = parseInt(req.query.page) || 0;
  const limit = parseInt(req.query.limit) || 10;
  const search = req.query.search || "";
  const offset = limit * page;

  try {
    // Hitung total user berdasarkan pencarian fullname
    const totalUser = await User.count({
      include: {
        model: DetailsUsers,
        as: "userDetails",
        attributes: ["fullname"],
        where: search ? { fullname: { [Op.substring]: search } } : {},
        required: true,
      },
      where: {
        isApproved: false,
        role_id: 1,
      },
    });

    const totalRows = totalUser;
    const totalPage = Math.ceil(totalRows / limit);

    // Ambil data user dengan fullname dari DetailUsers
    const users = await User.findAll({
      where: {
        isApproved: false,
        role_id: 1,
      },
      attributes: ["id", "email", "role_id", "isApproved"],
      include: [
        {
          model: DetailsUsers,
          as: "userDetails",
          attributes: ["fullname"], 
          required: true,
          where: search ? { fullname: { [Op.substring]: search } } : {},
        },
        {
          model: Role,
          as: "userRole",
          attributes: ["role_name"],
        },
      ],
      order: [["created_at", "DESC"]],
      offset: offset,
      limit: limit,
    });

    // Mapping data untuk response
    const data = users.map((user) => ({
      id: user.id,
      fullname: user.userDetails ? user.userDetails.fullname : null,
      email: user.email,
      role: user.userRole.role_name,
      isApproved: user.isApproved,
    }));

    res.status(200).json({
      data,
      page,
      limit,
      totalPage,
      totalRows,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


export const approveUsers = async (req, res) => {
  const { userIds } = req.body; // userIds dalam bentuk array

  try {
    if (!Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({ message: "Invalid user IDs." });
    }

    // Update semua user yang ID-nya ada di dalam array userIds
    const [updatedCount] = await User.update(
      { isApproved: true },
      { where: { id: userIds } }
    );

    if (updatedCount === 0) {
      return res.status(404).json({ message: "No users found to approve." });
    }

    return res.status(200).json({ message: "Users approved successfully.", updatedCount });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal server error" });
  }
};


export const approveUser = async (req, res) => {
  const { userId } = req.body;

  try {
    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found." });
    }

    user.isApproved = true;
    await user.save();

    return res.status(200).json({ message: "User approved successfully." });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal server error" });
  }
};


//get total users
export const getTotalUsers = async (req, res) => {
  try {
    const totalUser = await User.count({
      where: { role_id: 1 },
    });
    res.status(200).json({ totalUser }); 
  } catch (error) {
    res.status(500).json({ message: error.message }); 
  }
}

// Fungsi untuk mendapatkan detail pengguna berdasarkan ID
export const getUserDetails = async (req, res) => {
  const { id } = req.params;

  try {
    // Cari detail pengguna berdasarkan user_id
    const userDetails = await DetailsUsers.findOne({
      where: { user_id: id },
      include: [
        {
          model: User,
          attributes: ["email"], 
          as: "userDetails", 
        },
      ],
    });

    // Jika tidak ada detail pengguna, kirimkan fullname dan email saja
    if (!userDetails) {
      const user = await User.findOne({ where: { id } });
      return res.status(200).json({
        email: user.email,
        fullname: "-",
        phone_number: "-",
        photo_profile: "-",
      });
    }

    // Kirim response dengan data detail pengguna jika ada
    res.status(200).json({
      email: userDetails.userDetails.email,
      id: userDetails.user_id,
      fullname: userDetails ? userDetails.fullname : null,
      phone_number: userDetails.phone_number,
      photo_profile: userDetails.photo_profile,
    });
  } catch (error) {
    console.error(error); // Periksa pesan error lebih lanjut
    res.status(500).json({ message: error.message });
  }
};



export const getUserById = async (req, res) => {
  try {
    const user = await User.findOne({
      where: { id: req.params.id },
      attributes: ["id", "email", "role_id"],
      include: [
        {
          model: DetailsUsers,
          as: "userDetails",
          attributes: ["fullname"], 
          required: true,
        },
        {
          model: Role,
          as: "userRole",
          attributes: ["role_name"],
        },
      ],
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({
      id: user.id,
      fullname: user.userDetails ? user.userDetails.fullname : null,
      email: user.email,
      role: user.userRole.role_name,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


export const createUser = async (req, res) => {
  const { fullname, email, password, confirmPassword, roleName } = req.body;

  if (password !== confirmPassword) {
    return res.status(400).json({ message: "Passwords do not match" });
  }

  try {
    // Cek apakah email sudah digunakan
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ message: "Email already in use" });
    }

    // Cari role berdasarkan roleName
    const role = await Role.findOne({ where: { role_name: roleName } });
    if (!role) {
      return res.status(404).json({ message: "Role not found" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    // Buat user baru
    const newUser = await User.create({
      email,
      password: hashedPassword,
      role_id: role.id,
    });

    // Simpan fullname ke dalam DetailUsers
    await DetailsUsers.create({
      user_id: newUser.id,
      fullname,
    });

    res.status(201).json({
      message: "User created successfully",
      data: {
        id: newUser.id,
        fullname,
        email: newUser.email,
        role: role.role_name,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error.message, errors: error.errors });
  }
};



export const updateUser = async (req, res) => {
  const user = await User.findOne({
    where: { id: req.params.id },
  });

  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }

  const { fullname, email, password, confirmPassword, roleName } = req.body;
  let hashedPassword;
  if (!password) {
    hashedPassword = user.password;
  } else {
    if (password !== confirmPassword) {
      return res.status(400).json({ message: "Passwords do not match" });
    }
    hashedPassword = await bcrypt.hash(password, 10);
  }

  try {
    // Cari role berdasarkan roleName
    const role = await Role.findOne({ where: { role_name: roleName } });
    if (!role) {
      return res.status(404).json({ message: "Role not found" });
    }

    // Update data User
    await User.update(
      {
        email,
        password: hashedPassword,
        role_id: role.id,
      },
      {
        where: { id: user.id },
      }
    );

    // Update fullname di DetailUsers
    await DetailsUsers.update(
      { fullname },
      { where: { user_id: user.id } }
    );

    res.status(200).json({ message: "User updated successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};



export const deleteUser = async (req, res) => {
  const user = await User.findOne({
    where: { id: req.params.id },
  });

  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }

  try {
    const deletedUser = await User.destroy({
      where: { id: user.id },
    });

    res.status(200).json({ message: "User deleted", data: deletedUser });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

