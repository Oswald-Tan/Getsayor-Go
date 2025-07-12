import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";

const Address = db.define(
  "Address",
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
    recipient_name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    phone_number: {
      type: DataTypes.STRING(20),
      allowNull: false,
    },
    address_line_1: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    city: {
      type: DataTypes.STRING(100),
      defaultValue: "Manado",
    },
    state: {
      type: DataTypes.STRING(100),
      defaultValue: "Sulawesi Utara",
    },
    postal_code: {
      type: DataTypes.STRING(20),
      allowNull: true,
    },
    is_default: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    timestamps: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    tableName: "address",
  }
);

Address.belongsTo(User, { foreignKey: "user_id", as: "user" });
User.hasMany(Address, { foreignKey: 'user_id', as: 'user' });

export default Address;
