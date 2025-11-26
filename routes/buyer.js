const express = require("express");
const router = express.Router();
const { getDocs } = require("../db");

// Get all products
router.get("/products", async (req, res) => {
    try {
        const products = await getDocs("products");
        res.json(products);
    } catch (error) {
        console.error("Get products error:", error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
