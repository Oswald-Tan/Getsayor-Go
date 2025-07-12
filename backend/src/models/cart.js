import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";
import Products from "./product.js";

const Cart = db.define(
  "Cart",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    productId: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    status: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: 'active',
    } 
  },
  {
    timestamps: true,
    tableName: "carts",
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

User.hasMany(Cart, { foreignKey: "userId", as: "carts" });
Cart.belongsTo(User, { foreignKey: "userId", as: "user" });

Products.hasMany(Cart, { foreignKey: "productId", as: "carts" });
Cart.belongsTo(Products, { foreignKey: "productId", as: "product" });

export default Cart;
