const express = require("express");
const router = express.Router();

const NotHomeAlert = require("../models/not_home_alert.model");

// ✅ USER: create "not in home" alert
router.post("/", async (req, res) => {
  try {
    const { userId, message, lat, lng, address } = req.body;

    if (!userId) {
      return res
        .status(400)
        .json({ success: false, message: "userId is required" });
    }

    const created = await NotHomeAlert.create({
      userId,
      message: message || "Not in home",
      lat: lat ?? null,
      lng: lng ?? null,
      address: address || "",
      status: "OPEN",
    });

    return res.status(201).json({ success: true, data: created });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;