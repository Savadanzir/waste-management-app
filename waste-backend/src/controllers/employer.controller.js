const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Employer = require("../models/employer.model");
const PickupRequest = require("../models/pickup_request.model");

// EMPLOYER LOGIN
exports.employerLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    const employer = await Employer.findOne({
      email: (email || "").toLowerCase().trim(),
      isActive: true,
    });

    if (!employer) {
      return res.status(401).json({
        success: false,
        message: "Employer not found",
      });
    }

    const ok = await bcrypt.compare(password || "", employer.password);
    if (!ok) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    const token = jwt.sign(
      {
        id: employer._id,
        email: employer.email,
        role: "employer",
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    return res.json({
      success: true,
      token,
      employer: {
        id: employer._id,
        name: employer.name,
        email: employer.email,
      },
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
};

// GET APPROVED PICKUPS
exports.getApprovedPickups = async (req, res) => {
  try {
    const list = await PickupRequest.find({
      status: { $regex: "^APPROVED$", $options: "i" },
    }).sort({ updatedAt: -1, createdAt: -1 });

    return res.json({
      success: true,
      count: list.length,
      data: list,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
};