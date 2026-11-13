require("dotenv").config();
const mongoose = require("mongoose");
const Admin = require("../src/models/admin.model");

(async () => {
  await mongoose.connect(process.env.MONGO_URI);
  const admins = await Admin.find().select("email name createdAt");
  console.log(admins);
  process.exit(0);
})();
