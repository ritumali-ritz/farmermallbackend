const express = require("express");
const router = express.Router();
const { getDocs, addDoc, updateDoc, deleteDoc, queryDocs } = require("../db");
const db = require("../db");

const normalizeMediaPath = (value) => {
    if (value === undefined || value === null) return null;
    let trimmed = value.toString().trim();
    if (!trimmed) return null;
    if (/^https?:\/\//i.test(trimmed)) return trimmed;
    if (!trimmed.startsWith("/")) {
        trimmed = `/${trimmed}`;
    }
    return trimmed.replace(/\\/g, "/");
};

// Helper to attach local images based on product name
function attachLocalImage(product) {
    const p = { ...product };
    const name = (p.name || "").toLowerCase();

    // Prefer fast local images for popular items to avoid slow remote URLs
    if (name.includes("tomato")) {
        p.image_url = "/images/tomato.jpg";
    } else if (name.includes("potato")) {
        p.image_url = "/images/potato.jpg";
    } else if (name.includes("onion")) {
        p.image_url = "/images/onion.jpg";
    } else if (name.includes("milk")) {
        p.image_url = "/images/milk.jpg";
    }

    return p;
}

// ADD PRODUCT
router.post("/addProduct", async (req, res) => {
    try {
        const { farmer_id, name, price, quantity, description, image_url } = req.body;

        if (!farmer_id || !name || !price || !quantity) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        const normalizedImage = normalizeMediaPath(image_url);

        const productData = {
            farmer_id,
            name,
            price: parseFloat(price),
            quantity: parseInt(quantity),
            description: description || null,
            image_url: normalizedImage
        };

        const productId = await addDoc("products", productData);

        res.status(201).json({ message: "Product added successfully", product_id: productId });
    } catch (error) {
        console.error("Add product error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// GET ALL PRODUCTS
router.get("/allProducts", async (req, res) => {
    try {
        const products = await getDocs("products");

        // Attach local images for known products when image_url is missing
        const mapped = Array.isArray(products)
            ? products.map(attachLocalImage)
            : [];

        res.json(mapped);
    } catch (error) {
        console.error("Get products error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// GET PRODUCTS OF ONE FARMER
router.get("/myProducts/:farmer_id", async (req, res) => {
    try {
        const farmer_id = req.params.farmer_id;

        const products = await queryDocs("products", "farmer_id", "==", farmer_id);

        res.json(products);
    } catch (error) {
        console.error("Get farmer products error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// UPDATE PRODUCT
router.put("/updateProduct/:id", async (req, res) => {
    try {
        const product_id = req.params.id;
        const { name, price, quantity, description, image_url } = req.body;

        const updateData = {};
        if (name !== undefined) updateData.name = name;
        if (price !== undefined) updateData.price = parseFloat(price);
        if (quantity !== undefined) updateData.quantity = parseInt(quantity);
        if (description !== undefined) updateData.description = description || null;
        if (image_url !== undefined) {
            updateData.image_url = image_url === null ? null : normalizeMediaPath(image_url);
        }

        await updateDoc("products", product_id, updateData);

        res.json({ message: "Product updated successfully" });
    } catch (error) {
        console.error("Update product error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// DELETE PRODUCT
router.delete("/deleteProduct/:id", async (req, res) => {
    try {
        const product_id = req.params.id;

        await deleteDoc("products", product_id);

        res.json({ message: "Product deleted successfully" });
    } catch (error) {
        console.error("Delete product error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

module.exports = router;
