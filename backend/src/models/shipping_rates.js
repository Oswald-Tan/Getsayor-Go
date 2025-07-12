import { DataTypes } from "sequelize";
import db from "../config/database.js";
import City from "./city.js";

const ShippingRate = db.define("ShippingRate", {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  cityId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: City,
      key: "id",
    },
  },
  price: {
    type: DataTypes.FLOAT,
    allowNull: false,
  },
}, {
  timestamps: false,
  tableName: "shipping_rates",
});

City.hasOne(ShippingRate, { foreignKey: "cityId" });
ShippingRate.belongsTo(City, { foreignKey: "cityId" });

export default ShippingRate;
