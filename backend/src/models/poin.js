import { DataTypes } from "sequelize";
import db from "../config/database.js";

const Poin = db.define(
  "Poin",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    poin: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
     productId: {
      type: DataTypes.STRING, 
      allowNull: false,
    },
    promoProductId: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    timestamps: false,
    tableName: "poin",
  }
);

export default Poin;
