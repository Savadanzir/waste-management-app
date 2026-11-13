const mongoose = require("mongoose");
const User = require("../models/user.model");

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  phone: { type: String },
  role: { type: String, default: "user" },
});

module.exports = mongoose.model("User", userSchema);
