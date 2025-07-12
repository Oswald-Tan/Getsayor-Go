import { DataTypes } from "sequelize";
import db from "../config/database.js";

const User = db.define(
  "User",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    role_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    referralCode: {
      type: DataTypes.STRING,
      allowNull: true,
      unique: true,
    },
    referredBy: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: "users",
        key: "id",
      },
    },
    referralUsedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    resetOtp: { 
      type: DataTypes.STRING, 
      allowNull: true 
    },
    resetOtpExpires: { 
      type: DataTypes.DATE, 
      allowNull: true 
    },
    isApproved: { 
      type: DataTypes.BOOLEAN, 
      allowNull: false, 
      defaultValue: false,
    },
    fcm_token: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    timestamps: true,
    tableName: "users",
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

User.belongsTo(User, { as: "Referrer", foreignKey: "referredBy" });
User.hasMany(User, { as: "Referrals", foreignKey: "referredBy" });

export default User;
