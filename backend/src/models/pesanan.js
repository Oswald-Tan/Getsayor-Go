import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";

const Pesanan = db.define(
  "Pesanan",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    orderId: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true, 
    },
    idempotencyKey: {
      type: DataTypes.STRING,
      unique: true
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    invoiceNumber: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    metodePembayaran: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    hargaRp: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    hargaPoin: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    ongkir: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    totalBayar: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    paymentStatus: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: 'unpaid', //untuk COD
    },
    status: { 
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: 'pending',
    },
  },
  {
    timestamps: true,
    tableName: "pesanan",
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

// Pesanan.belongsTo(User, { foreignKey: 'userId' });
// User.hasMany(Pesanan, { foreignKey: 'userId' });

Pesanan.belongsTo(User, { foreignKey: 'userId', as: 'user' });
User.hasMany(Pesanan, { foreignKey: 'userId', as: 'pesanans' });



export default Pesanan;
