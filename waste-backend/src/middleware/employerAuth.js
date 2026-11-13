const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  try {
    const auth = req.headers.authorization || "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";

    if (!token) {
      return res.status(401).json({ success: false, message: "No token" });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // ✅ Require EMPLOYER role
    const role = (decoded.role || "").toUpperCase();
    if (role !== "EMPLOYER") {
      return res.status(403).json({ success: false, message: "Employer only" });
    }

    req.user = { id: decoded.id, email: decoded.email, role };
    next();
  } catch (e) {
    return res.status(401).json({ success: false, message: "Invalid token" });
  }
};