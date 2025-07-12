import { DataTypes } from "sequelize";
import db from "../config/database.js";

const Setting = db.define(
  "Setting",
  {
    key: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      primaryKey: true,
    },
    value: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    timestamps: false,
    tableName: "setting",
  }
);

export default Setting;
