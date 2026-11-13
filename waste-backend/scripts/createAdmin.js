require("dotenv").config();
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const Admin = require("../src/models/admin.model.js");


(async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);

    const email = "admin@ecogurd.com";
    const password = "Admin@123";

    const existing = await Admin.findOne({ email });

    if (existing) {
      console.log("Admin already exists");
      process.exit(0);
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await Admin.create({
      name: "Admin",
      email,
      password: hashedPassword,
    });

    console.log("Admin created successfully");
    console.log("Email:", email);
    console.log("Password:", password);

    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
