const mongoose = require("mongoose");

const pickupRequestSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true }, // ✅ MUST EXIST for user history filter

    name: { type: String, default: "User" },
    wasteType: { type: String, required: true },
    address: { type: String, required: true },
    pickupDate: { type: String, required: true },
    pickupTime: { type: String, required: true },
    notes: { type: String, default: "" },

    status: {
      type: String,
      enum: ["PENDING", "APPROVED", "REJECTED", "COLLECTED"],
      default: "PENDING",
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("PickupRequest", pickupRequestSchema);