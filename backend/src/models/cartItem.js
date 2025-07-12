import { DataTypes } from "sequelize";
import db from "../config/database.js";
import Products from "./product.js";

const CartItem = db.define(
  "CartItem",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    cartId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    productId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 1,
    },
    totalHargaPoin: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    totalHargaRp: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    timestamps: true,
    tableName: "cart_items",
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

Products.hasMany(CartItem, { foreignKey: "productId", as: "cartItems" });
CartItem.belongsTo(Products, { foreignKey: "productId", as: "product" });

export default CartItem;
