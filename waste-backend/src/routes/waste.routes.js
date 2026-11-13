const express = require("express");
const router = express.Router();

const wasteController = require("../controllers/waste.controller");

// user creates pickup request
router.post("/pickup", wasteController.createPickupRequest);

// (optional) list all pickups (for testing)
router.get("/pickups", wasteController.getAllPickups);
router.get("/pickups/user/:userId", wasteController.getPickupsByUser);

// NOT-IN-HOME alerts (map)
router.post("/not-home", wasteController.createNotHomeAlert);
router.get("/not-home/user/:userId", wasteController.getNotHomeAlertsByUser);

module.exports = router;