const multer = require("multer");
const path = require("path");
const fs = require("fs");

// ensure folder exists
const complaintsDir = path.join(__dirname, "..", "..", "uploads", "complaints");
fs.mkdirSync(complaintsDir, { recursive: true });

const storageComplaints = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, complaintsDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname || "").toLowerCase();
    const safeExt = ext || ".jpg";
    cb(null, Date.now() + "-" + Math.round(Math.random() * 1e9) + safeExt);
  },
});

// ✅ FIXED image filter (accept by mimetype OR extension)
function imageFileFilter(req, file, cb) {
  try {
    const mimetype = (file.mimetype || "").toLowerCase();
    const ext = path.extname(file.originalname || "").toLowerCase();

    const okByMime = mimetype.startsWith("image/");
    const okByExt = [".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp"].includes(ext);

    if (okByMime || okByExt) return cb(null, true);

    // ✅ return proper error (will be handled by route error handler / controller)
    return cb(new Error("Only image files are allowed"));
  } catch (e) {
    return cb(new Error("Invalid file"));
  }
}

const uploadComplaintImage = multer({
  storage: storageComplaints,
  fileFilter: imageFileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
});

module.exports = { uploadComplaintImage };