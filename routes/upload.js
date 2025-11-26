const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const router = express.Router();

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, "../uploads");
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        const prefix = req.path.includes('banner') ? 'banner-' : 'product-';
        cb(null, prefix + uniqueSuffix + path.extname(file.originalname));
    },
});

// File filter for images only
const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
        return cb(null, true);
    } else {
        cb(new Error("Only image files are allowed!"));
    }
};

const upload = multer({
    storage: storage,
    limits: { fileSize: 30 * 1024 * 1024 }, // 30MB limit
    fileFilter: fileFilter,
});

// Upload product image
router.post("/product", upload.single("image"), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: "No image file provided" });
    }

    try {
        // Return the file path relative to the server
        const imageUrl = `/uploads/${req.file.filename}`;
        console.log("Image uploaded successfully:", imageUrl);
        res.json({
            message: "Image uploaded successfully",
            imageUrl: imageUrl,
            filename: req.file.filename,
        });
    } catch (error) {
        console.error("Upload error:", error);
        res.status(500).json({ message: "Error uploading image: " + error.message });
    }
});

// Error handling middleware for multer
router.use((error, req, res, next) => {
    if (error instanceof multer.MulterError) {
        console.error("Multer error:", error);
        if (error.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({ message: "File too large. Maximum size is 30MB" });
        }
        return res.status(400).json({ message: "Upload error: " + error.message });
    }
    if (error) {
        console.error("Upload error:", error);
        return res.status(400).json({ message: error.message || "Upload failed" });
    }
    next();
});

// Upload banner image
router.post("/banner", upload.single("image"), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: "No image file provided" });
    }

    // Return the file path relative to the server
    const imageUrl = `/uploads/${req.file.filename}`;
    res.json({
        message: "Banner uploaded successfully",
        imageUrl: imageUrl,
        filename: req.file.filename,
    });
});

module.exports = router;

