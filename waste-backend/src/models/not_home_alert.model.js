const mongoose = require("mongoose");

const NotHomeAlertSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true },
    userName: { type: String, default: "User" },
    houseNo: { type: String, default: "" },
    address: { type: String, default: "" },
    place: { type: String, default: "" },

    // Map point
    lat: { type: Number, required: true },
    lng: { type: Number, required: true },

    message: { type: String, default: "NOT_IN_HOME" },
    status: { type: String, default: "OPEN" }, // OPEN | RESOLVED
    
    assignedEmployerId: { type: String, default: "" },
    areaName: { type: String, default: "" },

  },
  { timestamps: true }
);

module.exports = mongoose.model("NotHomeAlert", NotHomeAlertSchema);