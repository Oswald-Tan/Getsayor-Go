import { DataTypes } from "sequelize";
import db from "../config/database.js";
import Poin from "./poin.js";

const HargaPoin = db.define(
  "HargaPoin",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    harga: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    timestamps: false,
    tableName: "hargapoin",
  }
);


export default HargaPoin;
