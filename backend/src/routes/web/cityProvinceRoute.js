import express from "express";
  import { getProvinceAndCity, getCity, createProvinceAndCity, deleteProvinceAndCities } from "../../controllers/cityProvinceController.js";
  import { verifyUser, adminOnly } from "../../middleware/authUser.js";
  
  const router = express.Router();
  
  router.get("/", getProvinceAndCity);
  router.get("/cities", verifyUser, adminOnly, getCity);
  router.post("/", createProvinceAndCity);
  router.delete("/:id", deleteProvinceAndCities);
  
  export default router;
  