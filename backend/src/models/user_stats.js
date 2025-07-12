import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js"; 

const UserStats = db.define(
  "UserStats",
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
    last_login: {
      type: DataTypes.DATE,
    },
    total_logins: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
  },
  {
    timestamps: false, 
    tableName: "user_stats",
  }
);

// Relasi antara User dan UserStats (One-to-One)
User.hasOne(UserStats, { foreignKey: "user_id" });
UserStats.belongsTo(User, { foreignKey: "user_id" });

export default UserStats;
