import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";
import Products from "./product.js";

const Favorite = db.define(
  "Favorite",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users", // Tetap gunakan string nama tabel
        key: "id",
      },
    },
    productId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "products", // Tetap gunakan string nama tabel
        key: "id",
      },
    },
  },
  {
    timestamps: true,
    tableName: "favorites",
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      {
        unique: true,
        fields: ["userId", "productId"],
      },
    ],
  }
);

User.hasMany(Favorite, { foreignKey: "userId" });
Favorite.belongsTo(User, { foreignKey: "userId" });

Products.hasMany(Favorite, { foreignKey: "productId" });
Favorite.belongsTo(Products, { foreignKey: "productId" });

export default Favorite;
