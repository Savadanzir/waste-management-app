require("dotenv").config();
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const Admin = require("../src/models/admin.model");

(async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);

    const email = "admin@ecogurd.com";
    const password = "Admin@123";
    const hashed = await bcrypt.hash(password, 10);

    // Upsert: if exists update, else create
    const admin = await Admin.findOneAndUpdate(
      { email: email.toLowerCase().trim() },
      { name: "Admin", email: email.toLowerCase().trim(), password: hashed },
      { new: true, upsert: true }
    );

    console.log("✅ Admin ready:");
    console.log("Email:", admin.email);
    console.log("Password:", password);

    process.exit(0);
  } catch (e) {
    console.error("❌ Error:", e);
    process.exit(1);
  }
})();
