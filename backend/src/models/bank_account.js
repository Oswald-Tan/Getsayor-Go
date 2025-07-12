import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";

const BankAccount = db.define(
  "BankAccount",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
      onDelete: "CASCADE",
    },
    accountHolder: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    bankName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    accountNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
  },
  {
    timestamps: true,
    tableName: "bank_accounts",
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);

// Relasi dengan User
User.hasOne(BankAccount, { foreignKey: "userId", as: "bankAccount" });
BankAccount.belongsTo(User, { foreignKey: "userId", as: "user" });

export default BankAccount;
