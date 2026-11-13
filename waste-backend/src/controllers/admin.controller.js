const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const Admin = require("../models/admin.model");

// models
const Complaint = require("../models/complaint.model");
const PickupRequest = require("../models/pickup_request.model");
const NotHomeAlert = require("../models/not_home_alert.model");
const Employer = require("../models/employer.model");


// -------------------- AUTH --------------------
exports.adminLogin = async (req, res) => {
  try {

    const { email, password } = req.body;

    const admin = await Admin.findOne({
      email: (email || "").toLowerCase().trim()
    });

    if (!admin) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials"
      });
    }

    // FIX: compare plain password with database
    if (admin.password !== password) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials"
      });
    }

    const token = jwt.sign(
      {
        id: admin._id,
        email: admin.email,
        role: admin.role || "admin"
      },
      process.env.JWT_SECRET || "adminsecret",
      { expiresIn: "7d" }
    );

    return res.json({
      success: true,
      token,
      admin: {
        id: admin._id,
        name: admin.name,
        email: admin.email
      }
    });

  } catch (e) {

    console.error("ADMIN LOGIN ERROR:", e);

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


// -------------------- COMPLAINTS --------------------
exports.getAllComplaints = async (req, res) => {
  try {

    const list = await Complaint.find().sort({ createdAt: -1 });

    return res.json({
      success: true,
      data: list
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


exports.updateComplaintStatus = async (req, res) => {
  try {

    const { id } = req.params;
    const { status } = req.body;

    const updated = await Complaint.findByIdAndUpdate(
      id,
      { status },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Complaint not found"
      });
    }

    return res.json({
      success: true,
      data: updated
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


// -------------------- PICKUPS --------------------
exports.getAllPickups = async (req, res) => {
  try {

    const list = await PickupRequest.find().sort({ createdAt: -1 });

    return res.json({
      success: true,
      data: list
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


exports.updatePickupStatus = async (req, res) => {
  try {

    const { id } = req.params;
    const { status } = req.body;

    const updated = await PickupRequest.findByIdAndUpdate(
      id,
      { status: (status || "PENDING").toUpperCase() },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Pickup not found"
      });
    }

    return res.json({
      success: true,
      data: updated
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


exports.approvePickup = async (req, res) => {
  try {

    const { id } = req.params;

    const updated = await PickupRequest.findByIdAndUpdate(
      id,
      { status: "APPROVED" },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Pickup not found"
      });
    }

    return res.json({
      success: true,
      data: updated
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


exports.rejectPickup = async (req, res) => {
  try {

    const { id } = req.params;

    const updated = await PickupRequest.findByIdAndUpdate(
      id,
      { status: "REJECTED" },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Pickup not found"
      });
    }

    return res.json({
      success: true,
      data: updated
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


exports.markPickupCollected = async (req, res) => {
  try {

    const { id } = req.params;

    const updated = await PickupRequest.findByIdAndUpdate(
      id,
      { status: "COLLECTED" },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Pickup not found"
      });
    }

    return res.json({
      success: true,
      data: updated
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


// -------------------- NOT HOME ALERTS --------------------
exports.getNotHomeAlerts = async (req, res) => {
  try {

    const list = await NotHomeAlert.find({ status: "OPEN" }).sort({
      createdAt: -1
    });

    return res.json({
      success: true,
      data: list
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


exports.resolveNotHomeAlert = async (req, res) => {
  try {

    const { id } = req.params;

    const updated = await NotHomeAlert.findByIdAndUpdate(
      id,
      { status: "RESOLVED" },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Alert not found"
      });
    }

    return res.json({
      success: true,
      data: updated
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


// -------------------- ASSIGN ALERT --------------------
exports.assignNotHomeAlertToEmployer = async (req, res) => {
  try {

    const { id } = req.params;
    const { employerId, areaName } = req.body;

    const updated = await NotHomeAlert.findByIdAndUpdate(
      id,
      {
        assignedEmployerId: employerId,
        areaName: areaName || ""
      },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Alert not found"
      });
    }

    return res.json({
      success: true,
      data: updated
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};


// -------------------- CREATE EMPLOYER --------------------
exports.createEmployer = async (req, res) => {
  try {

    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "name, email, password are required"
      });
    }

    const existing = await Employer.findOne({
      email: email.toLowerCase().trim()
    });

    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Employer already exists"
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const created = await Employer.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password: hashedPassword
    });

    return res.status(201).json({
      success: true,
      data: {
        id: created._id,
        name: created.name,
        email: created.email
      }
    });

  } catch (e) {

    return res.status(500).json({
      success: false,
      message: e.message
    });

  }
};