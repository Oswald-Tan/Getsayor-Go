import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";

const UserPoints = db.define(
  "UserPoints",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    points: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
  },
  {
    timestamps: true,
    tableName: "user_points",
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

User.hasOne(UserPoints, { foreignKey: "userId", as: "userPoints" });
UserPoints.belongsTo(User, { foreignKey: "userId", as: "user" });

export default UserPoints;
