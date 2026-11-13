const express = require("express");
const router = express.Router();

const { registerUser, loginUser, getUsers } = require("../controllers/user.controller");

// REGISTER
router.post("/register", registerUser);

// LOGIN
router.post("/login", loginUser);

// GET ALL USERS
router.get("/", getUsers);

module.exports = router;
