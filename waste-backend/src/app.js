require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
const connectDB = require("./config/db");

const userRoutes = require("./routes/user.routes");
const wasteRoutes = require("./routes/waste.routes");
const adminRoutes = require("./routes/admin.routes");

// NOT HOME ROUTES
const notHomeRoutes = require("./routes/not_home.routes");

// EMPLOYER ROUTES
const employerRoutes = require("./src/routes/employer.routes");

const app = express();
app.use(cors());
app.use(express.json());

// connect database
connectDB();

// ✅ AUTO CREATE ADMIN
mongoose.connection.once("open", async () => {
  console.log("MongoDB connected");

  const adminCollection = mongoose.connection.collection("admins");

  const admin = await adminCollection.findOne({
    email: "admin@ecogurd.com"
  });

  if (!admin) {
    await adminCollection.insertOne({
      email: "admin@ecogurd.com",
      password: "Admin@123",
      role: "admin"
    });

    console.log("Default admin created");
  } else {
    console.log("Admin already exists");
  }
});

app.use("/api/users", userRoutes);
app.use("/api/waste", wasteRoutes);
app.use("/api/admin", adminRoutes);

// Not-in-home API
app.use("/api/not-home", notHomeRoutes);

// Employer API
app.use("/api/employer", employerRoutes);

// JSON 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
    path: req.path,
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () =>
  console.log(`Server running on port ${PORT}`)
);