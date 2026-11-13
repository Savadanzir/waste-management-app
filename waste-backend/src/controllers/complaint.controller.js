const Complaint = require("../models/complaint.model");

// ======================================================
// ✅ USER: CREATE COMPLAINT (WITH IMAGE)
// ======================================================
exports.createComplaint = async (req, res) => {
  try {
    const { userId, name, complaint } = req.body;

    if (!name || !complaint) {
      return res.status(400).json({
        success: false,
        message: "name and complaint are required",
      });
    }

    // ✅ Accept BOTH "image" or "file"
    const file = (req.files && req.files.length > 0) ? req.files[0] : null;

    const imageUrl = file ? `/uploads/complaints/${file.filename}` : "";

    const created = await Complaint.create({
      userId: userId || null,
      name,
      complaint,
      imageUrl,

      status: "PENDING",

      // viewed notification fields
      isViewed: false,
      viewedAt: null,
      viewMessage: "",
    });

    return res.status(201).json({ success: true, data: created });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ======================================================
// ✅ ADMIN: GET ALL COMPLAINTS
// ======================================================
exports.getComplaintsAdmin = async (req, res) => {
  try {
    const list = await Complaint.find().sort({ createdAt: -1 });
    return res.json({ success: true, data: list });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ======================================================
// ✅ ADMIN: MARK COMPLAINT AS VIEWED
// (Call this when admin opens complaint details)
// ======================================================
exports.markComplaintViewed = async (req, res) => {
  try {
    const { id } = req.params;

    const updated = await Complaint.findByIdAndUpdate(
      id,
      {
        isViewed: true,
        viewedAt: new Date(),
        viewMessage: "Your complaint is viewed",
      },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ success: false, message: "Complaint not found" });
    }

    return res.json({ success: true, data: updated });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

// ======================================================
// ✅ USER: GET OWN COMPLAINTS (STATUS + VIEW MESSAGE)
// ======================================================
exports.getComplaintsByUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const list = await Complaint.find({ userId }).sort({ createdAt: -1 });

    return res.json({ success: true, data: list });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};