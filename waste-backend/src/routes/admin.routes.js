const express = require("express");
const router = express.Router();

const adminCtrl = require("../controllers/admin.controller");
const adminAuth = require("../middleware/adminAuth"); // MUST export a function (req,res,next)

console.log("adminAuth typeof:", typeof adminAuth);
console.log("getAllComplaints typeof:", typeof adminCtrl.getAllComplaints);
console.log("updateComplaintStatus typeof:", typeof adminCtrl.updateComplaintStatus);
console.log("getAllPickups typeof:", typeof adminCtrl.getAllPickups);
console.log("getNotHomeAlerts typeof:", typeof adminCtrl.getNotHomeAlerts);
console.log("resolveNotHomeAlert typeof:", typeof adminCtrl.resolveNotHomeAlert);

// auth
router.post("/login", adminCtrl.adminLogin);
router.post("/employers", adminAuth, adminCtrl.createEmployer);

// complaints
router.get("/complaints", adminAuth, adminCtrl.getAllComplaints);
router.patch("/complaints/:id/status", adminAuth, adminCtrl.updateComplaintStatus);

// pickups
router.get("/pickups", adminAuth, adminCtrl.getAllPickups);
router.patch("/pickups/:id/status", adminAuth, adminCtrl.updatePickupStatus);
router.patch("/pickups/:id/approve", adminAuth, adminCtrl.approvePickup);
router.patch("/pickups/:id/reject", adminAuth, adminCtrl.rejectPickup);
router.patch("/pickups/:id/collected", adminAuth, adminCtrl.markPickupCollected);
router.patch("/not-home/:id/assign", adminAuth, adminCtrl.assignNotHomeAlertToEmployer);

// NOT-IN-HOME
router.get("/not-home", adminAuth, adminCtrl.getNotHomeAlerts);
router.patch("/not-home/:id/resolve", adminAuth, adminCtrl.resolveNotHomeAlert);

module.exports = router;