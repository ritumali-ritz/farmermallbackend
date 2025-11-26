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

// Get all users
router.get("/users", async (req, res) => {
    try {
        const users = await getDocs("users");
        const userList = users.map(user => ({
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            phone: user.phone || null,
            created_at: user.created_at
        }));

        // Sort by created_at descending
        userList.sort((a, b) => {
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return bTime - aTime;
        });

        res.json(userList);
    } catch (error) {
        console.error("Admin users fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Get all farmers
router.get("/farmers", async (req, res) => {
    try {
        const farmers = await queryDocs("users", "role", "==", "farmer");
        const allProducts = await getDocs("products");

        // Count products per farmer
        const productCounts = {};
        allProducts.forEach(product => {
            if (product.farmer_id) {
                productCounts[product.farmer_id] = (productCounts[product.farmer_id] || 0) + 1;
            }
        });

        const farmersWithCounts = farmers.map(farmer => ({
            id: farmer.id,
            name: farmer.name,
            email: farmer.email,
            phone: farmer.phone || null,
            created_at: farmer.created_at,
            product_count: productCounts[farmer.id] || 0
        }));

        // Sort by created_at descending
        farmersWithCounts.sort((a, b) => {
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return bTime - aTime;
        });

        res.json(farmersWithCounts);
    } catch (error) {
        console.error("Admin farmers fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Get all products
router.get("/products", async (req, res) => {
    try {
        const products = await getDocs("products");
        const allUsers = await getDocs("users");
        const userMap = {};
        allUsers.forEach(user => {
            userMap[user.id] = user;
        });

        const productsWithFarmers = products.map(product => ({
            ...product,
            farmer_name: userMap[product.farmer_id]?.name || null,
            farmer_email: userMap[product.farmer_id]?.email || null
        }));

        // Sort by created_at descending
        productsWithFarmers.sort((a, b) => {
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return bTime - aTime;
        });

        res.json(productsWithFarmers);
    } catch (error) {
        console.error("Admin products fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Delete product
router.delete("/products/:id", async (req, res) => {
    try {
        await deleteDoc("products", req.params.id);
        res.json({ message: "Product deleted successfully" });
    } catch (error) {
        console.error("Admin product delete error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Delete user
router.delete("/users/:id", async (req, res) => {
    try {
        await deleteDoc("users", req.params.id);
        res.json({ message: "User deleted successfully" });
    } catch (error) {
        console.error("Admin user delete error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Get all banners
router.get("/banners", async (req, res) => {
    try {
        const banners = await queryDocs("banners", "status", "==", "active");
        banners.sort((a, b) => (a.display_order || 0) - (b.display_order || 0));
        res.json(banners);
    } catch (error) {
        console.error("Banner fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Get all banners (including inactive) for admin
router.get("/banners/all", async (req, res) => {
    try {
        const banners = await getDocs("banners");
        banners.sort((a, b) => {
            const orderDiff = (a.display_order || 0) - (b.display_order || 0);
            if (orderDiff !== 0) return orderDiff;
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return bTime - aTime;
        });
        res.json(banners);
    } catch (error) {
        console.error("Banner fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Create banner
router.post("/banners", async (req, res) => {
    try {
        const { title, image_url, link_url, display_order, status } = req.body;

        const normalizedImage = normalizeMediaPath(image_url);
        if (!normalizedImage) {
            return res.status(400).json({ message: "Image URL is required" });
        }
        const normalizedLink = normalizeMediaPath(link_url);

        const bannerData = {
            title: title || null,
            image_url: normalizedImage,
            link_url: normalizedLink,
            display_order: display_order || 0,
            status: status || 'active'
        };

        const bannerId = await addDoc("banners", bannerData);
        res.status(201).json({ message: "Banner created", id: bannerId });
    } catch (error) {
        console.error("Banner create error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Update banner
router.put("/banners/:id", async (req, res) => {
    try {
        const { title, image_url, link_url, display_order, status } = req.body;
        const updateData = {};

        if (title !== undefined) updateData.title = title;
        if (image_url !== undefined) updateData.image_url = normalizeMediaPath(image_url);
        if (link_url !== undefined) updateData.link_url = normalizeMediaPath(link_url);
        if (display_order !== undefined) updateData.display_order = display_order;
        if (status !== undefined) updateData.status = status;

        if (Object.keys(updateData).length === 0) {
            return res.status(400).json({ message: "No fields to update" });
        }

        await updateDoc("banners", req.params.id, updateData);
        res.json({ message: "Banner updated" });
    } catch (error) {
        console.error("Banner update error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Delete banner
router.delete("/banners/:id", async (req, res) => {
    try {
        await deleteDoc("banners", req.params.id);
        res.json({ message: "Banner deleted" });
    } catch (error) {
        console.error("Banner delete error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Get statistics
router.get("/stats", async (req, res) => {
    try {
        const users = await getDocs("users");
        const products = await getDocs("products");
        const orders = await getDocs("orders");

        const stats = {
            totalUsers: users.length,
            totalFarmers: users.filter(u => u.role === 'farmer').length,
            totalBuyers: users.filter(u => u.role === 'buyer').length,
            totalProducts: products.length,
            totalOrders: orders.length
        };

        res.json(stats);
    } catch (error) {
        console.error("Stats fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

module.exports = router;
