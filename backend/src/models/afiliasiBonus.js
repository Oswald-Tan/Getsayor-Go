import { DataTypes } from "sequelize";
import db from "../config/database.js";
import User from "./user.js";
import Pesanan from "./pesanan.js";

const AfiliasiBonus = db.define('AfiliasiBonus', {
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
  referralUserId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  pesananId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'pesanan',
      key: 'id'
    }
  },
  bonusAmount: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  bonusLevel: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  expiryDate: {
    type: DataTypes.DATE,
    allowNull: false
  },
  status: { 
    type: DataTypes.ENUM('pending', 'claimed', 'expired'),
    allowNull: false,
    defaultValue: 'pending' 
  },
  claimedAt: {  
    type: DataTypes.DATE,
    allowNull: true
  },
  bonusReceivedAt: {  
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,  
  }
}, {
  timestamps: false,
  tableName: 'afiliasi_bonus',
});

// Relasi
AfiliasiBonus.belongsTo(User, { as: 'User', foreignKey: 'userId' });
AfiliasiBonus.belongsTo(User, { as: 'ReferralUser', foreignKey: 'referralUserId' });
AfiliasiBonus.belongsTo(Pesanan, { foreignKey: 'pesananId' });

export default AfiliasiBonus;
