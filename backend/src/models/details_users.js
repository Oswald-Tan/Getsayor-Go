import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";

const DetailsUsers = db.define(
  "DetailsUsers",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    fullname: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    phone_number: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    photo_profile: {
      type: DataTypes.STRING(255), 
    },
  },
  {
    timestamps: false,
    tableName: "details_users",
  }
);

User.hasOne(DetailsUsers, { foreignKey: "user_id", as: "userDetails" });
DetailsUsers.belongsTo(User, { foreignKey: "user_id", as: "userDetails" });


export default DetailsUsers;
