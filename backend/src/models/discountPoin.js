import { DataTypes } from "sequelize";
import db from "../config/database.js";
import Poin from "./poin.js";

const Discount = db.define(
  "Discount",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    percentage: {
      type: DataTypes.FLOAT,
      allowNull: false,
    },
    poinId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    timestamps: false,
    tableName: "discounts",
  }
);

Poin.hasOne(Discount, { foreignKey: "poinId", as: "discount" });
Discount.belongsTo(Poin, { foreignKey: "poinId", as: "poin" });

export default Discount;
