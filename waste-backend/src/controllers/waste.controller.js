const PickupRequest = require("../models/pickup_request.model");

// ✅ NEW (ADD): Not in home alert model
const NotHomeAlert = require("../models/not_home_alert.model");

// ======================================================
// USER: CREATE PICKUP REQUEST
// ======================================================
exports.createPickupRequest = async (req, res) => {
  try {
    const {
      userId,
      name,
      wasteType,
      address,
      pickupDate,
      pickupTime,
      notes,
    } = req.body;

    // ✅ Keep the same fields, but also ensure userId is checked (your message already says userId required)
    if (!userId || !wasteType || !address || !pickupDate || !pickupTime) {
      return res.status(400).json({
        success: false,
        message: "userId, wasteType, address, pickupDate, pickupTime are required",
      });
    }

    const created = await PickupRequest.create({
      userId,
      name: name || "User",
      wasteType,
      address,
      pickupDate,
      pickupTime,
      notes: notes || "",
      status: "PENDING",
    });

    return res.status(201).json({ success: true, data: created });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ======================================================
// OPTIONAL: GET ALL PICKUPS (TEST)
// ======================================================
exports.getAllPickups = async (req, res) => {
  try {
    const list = await PickupRequest.find().sort({ createdAt: -1 });
    return res.json({ success: true, data: list });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ======================================================
// USER: GET PICKUPS BY USER (HISTORY / RECENTS)
// ======================================================
exports.getPickupsByUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const list = await PickupRequest.find({ userId }).sort({
      createdAt: -1,
    });

    return res.json({ success: true, data: list });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ======================================================
// ✅ USER: CREATE "NOT IN HOME" ALERT (MAP)
// ======================================================
exports.createNotHomeAlert = async (req, res) => {
  try {
    // ✅ Match Flutter payload fields (recommended)
    const { userId, userName, houseNo, address, place, lat, lng, message } = req.body;

    if (!userId || lat === undefined || lng === undefined) {
      return res.status(400).json({
        success: false,
        message: "userId, lat, lng are required",
      });
    }

    const created = await NotHomeAlert.create({
      userId,
      userName: userName || "User",
      houseNo: houseNo || "",
      address: address || "",
      place: place || "",
      lat,
      lng,
      message: message || "NOT_IN_HOME",
      status: "OPEN",
    });

    return res.status(201).json({ success: true, data: created });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ======================================================
// ✅ USER: LIST OWN NOT-HOME ALERTS (optional)
// ======================================================
exports.getNotHomeAlertsByUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const list = await NotHomeAlert.find({ userId }).sort({ createdAt: -1 });
    return res.json({ success: true, data: list });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};