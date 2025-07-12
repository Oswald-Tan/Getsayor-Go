import { DataTypes } from "sequelize";
import db from "../config/database.js";
import Pesanan from "./pesanan.js";
import Products from "./product.js";

const OrderItem = db.define(
  "OrderItem",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    pesananId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'pesanan',
        key: 'id',
      },
    },
    productId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    namaProduk: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    harga: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    jumlah: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    berat: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    satuan: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    totalHarga: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    timestamps: true,
    tableName: "order_items",
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

// Relasi OrderItem ke Pesanan (banyak ke satu)
OrderItem.belongsTo(Pesanan, { foreignKey: 'pesananId', as: 'pesanan' });
Pesanan.hasMany(OrderItem, { foreignKey: 'pesananId', as: 'orderItems' });

// Relasi OrderItem ke Products (banyak ke satu)
OrderItem.belongsTo(Products, { foreignKey: 'productId', as: 'produk' });
Products.hasMany(OrderItem, { foreignKey: 'productId', as: 'orderItems' });

export default OrderItem;