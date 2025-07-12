import jwt from "jsonwebtoken";

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "Unauthorized, token required" });
  }

  try {
    const decoded = jwt.verify(token, process.env.TOKEN_JWT, {
      algorithms: ["HS256"],
    });
    req.user = decoded; // Menyimpan informasi user di request
    next();
  } catch (error) {
    return res.status(403).json({ message: "Token invalid or expired" });
  }
};

export default authMiddleware;