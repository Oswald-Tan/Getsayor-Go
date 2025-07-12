import { DataTypes } from "sequelize";
import db from "../config/database.js";
import Province from "./province.js";

const City  = db.define(
  "City ",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    provinceId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    timestamps: false,
    tableName: "cities",
  }
);

City.belongsTo(Province, { foreignKey: 'provinceId' });
Province.hasMany(City, { as: 'cities', foreignKey: 'provinceId' });

export default City ;
