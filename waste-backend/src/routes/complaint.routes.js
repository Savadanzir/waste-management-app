const express = require("express");
const router = express.Router();

const { uploadComplaintImage } = require("../middleware/upload");
const adminAuth = require("../middleware/adminAuth");
const complaintController = require("../controllers/complaint.controller");

// ✅ USER: submit complaint + image
// ✅ FIX: accept any file field name (prevents Multer Unexpected field)
router.post("/", uploadComplaintImage.any(), complaintController.createComplaint);

// ✅ ADMIN: view all complaints
router.get("/admin", adminAuth, complaintController.getComplaintsAdmin);

// ✅ ADMIN: mark complaint as viewed
router.patch("/admin/:id/viewed", adminAuth, complaintController.markComplaintViewed);

// ✅ USER: view own complaints + viewed status
router.get("/user/:userId", complaintController.getComplaintsByUser);

module.exports = router;