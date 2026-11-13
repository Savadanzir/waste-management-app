const express = require("express");
const router = express.Router();
const employerController = require("../controllers/employer.controller");

router.post("/login", employerController.employerLogin);
router.get("/approved-pickups", employerController.getApprovedPickups);

module.exports = router;