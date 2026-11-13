const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const userRoutes = require("./src/routes/user.routes");
const adminRoutes = require("./src/routes/admin.routes");

// ✅ ADD THESE TWO LINES
const complaintRoutes = require("./src/routes/complaint.routes");
const wasteRoutes = require("./src/routes/waste.routes");

// ✅ ADD THIS LINE
const employerRoutes = require("./src/routes/employer.routes");

const app = express();

app.use(cors());
app.use(express.json());

// ✅ serve uploaded complaint images
app.use("/uploads", express.static("uploads"));

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.log("MongoDB Error:", err));

app.use("/api/users", userRoutes);
app.use("/api/admin", adminRoutes);

// ✅ routes
app.use("/api/complaints", complaintRoutes);
app.use("/api/waste", wasteRoutes);

// ✅ ADD THIS LINE
app.use("/api/employer", employerRoutes);

// =======================================================
// ✅ ADD THIS AT THE VERY BOTTOM (ERROR HANDLER)
// =======================================================
app.use((err, req, res, next) => {
  if (err) {
    return res.status(400).json({
      success: false,
      message: err.message || "Upload error",
    });
  }
  next();
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));