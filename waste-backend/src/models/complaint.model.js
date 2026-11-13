const mongoose = require("mongoose");

const complaintSchema = new mongoose.Schema(
  {
    userId: { type: String, default: null },

    name: { type: String, required: true },
    complaint: { type: String, required: true },

    // saved image URL like: /uploads/complaints/<filename>
    imageUrl: { type: String, default: "" },

    status: {
      type: String,
      enum: ["PENDING", "RESOLVED"],
      default: "PENDING",
    },

    // ✅ Viewed notification fields
    isViewed: { type: Boolean, default: false },
    viewedAt: { type: Date, default: null },
    viewMessage: { type: String, default: "" },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Complaint", complaintSchema);