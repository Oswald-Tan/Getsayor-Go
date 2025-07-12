import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";

const TotalBonus = db.define('TotalBonus', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  totalBonus: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0, 
  },
}, {
  timestamps: false,
  tableName: 'total_bonus',
});

// Relasi
TotalBonus.belongsTo(User, { foreignKey: 'userId' });

export default TotalBonus;
