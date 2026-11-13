const mongoose = require("mongoose");

const pickupSchema = new mongoose.Schema(
  {
    wasteType: { type: String, required: true },
    address: { type: String, required: true },
    pickupDate: { type: String, required: true }, // store as ISO string or yyyy-mm-dd
    pickupTime: { type: String, required: true }, // "10:30 AM"
    notes: { type: String, default: "" },

    status: { type: String, default: "PENDING" }, // PENDING | APPROVED | REJECTED | COLLECTED
  },
  { timestamps: true }
);

module.exports = mongoose.model("PickupRequest", pickupSchema);