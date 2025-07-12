import { DataTypes } from "sequelize";
import db from "../config/database.js";

const Province  = db.define(
  "Province ",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    timestamps: false,
    tableName: "provinces",
  }
);

export default Province ;
