const express = require("express");
const router = express.Router();
const { getDocs, addDoc, updateDoc, deleteDoc, queryDocs } = require("../db");
const db = require("../db");

// Get subscriptions for a buyer
router.get("/buyer/:buyer_id", async (req, res) => {
    try {
        const subscriptions = await queryDocs("subscriptions", "buyer_id", "==", req.params.buyer_id);

        // Get product and farmer details
        const subscriptionsWithDetails = await Promise.all(subscriptions.map(async (sub) => {
            let product = null;
            if (sub.product_id) {
                const productDoc = await db.collection("products").doc(sub.product_id).get();
                product = productDoc.exists ? { id: productDoc.id, ...productDoc.data() } : null;
            }

            const farmerDoc = await db.collection("users").doc(sub.farmer_id).get();
            const farmer = farmerDoc.exists ? { id: farmerDoc.id, ...farmerDoc.data() } : null;

            return {
                ...sub,
                product_name: product?.name || null,
                price: product?.price || null,
                image_url: product?.image_url || null,
                farmer_name: farmer?.name || null,
                farmer_phone: farmer?.phone || null
            };
        }));

        // Sort by created_at descending
        subscriptionsWithDetails.sort((a, b) => {
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return bTime - aTime;
        });

        res.json(subscriptionsWithDetails);
    } catch (error) {
        console.error("Subscription fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Get subscriptions for a farmer
router.get("/farmer/:farmer_id", async (req, res) => {
    try {
        const subscriptions = await queryDocs("subscriptions", "farmer_id", "==", req.params.farmer_id);

        // Get product and buyer details
        const subscriptionsWithDetails = await Promise.all(subscriptions.map(async (sub) => {
            let product = null;
            if (sub.product_id) {
                const productDoc = await db.collection("products").doc(sub.product_id).get();
                product = productDoc.exists ? { id: productDoc.id, ...productDoc.data() } : null;
            }

            const buyerDoc = await db.collection("users").doc(sub.buyer_id).get();
            const buyer = buyerDoc.exists ? { id: buyerDoc.id, ...buyerDoc.data() } : null;

            return {
                ...sub,
                product_name: product?.name || null,
                price: product?.price || null,
                image_url: product?.image_url || null,
                buyer_name: buyer?.name || null,
                buyer_phone: buyer?.phone || null,
                buyer_email: buyer?.email || null
            };
        }));

        // Sort by created_at descending
        subscriptionsWithDetails.sort((a, b) => {
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return bTime - aTime;
        });

        res.json(subscriptionsWithDetails);
    } catch (error) {
        console.error("Subscription fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Create subscription
const getDefaultFarmerId = async () => {
    try {
        const farmers = await queryDocs("users", "role", "==", "farmer");
        if (farmers.length === 0) return null;
        // Sort by id and get first one
        farmers.sort((a, b) => {
            const aId = parseInt(a.id) || 0;
            const bId = parseInt(b.id) || 0;
            return aId - bId;
        });
        return farmers[0].id;
    } catch (error) {
        console.error("Get default farmer error:", error);
        return null;
    }
};

router.post("/create", async (req, res) => {
    try {
        let { farmer_id, buyer_id, service_type, product_id, quantity, frequency, start_date, end_date } = req.body;

        if (!buyer_id || !service_type || !quantity || !start_date) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        if (!farmer_id) {
            farmer_id = await getDefaultFarmerId();
            if (!farmer_id) {
                return res.status(400).json({ message: "No farmers available to fulfill this subscription yet." });
            }
        }

        const subscriptionData = {
            farmer_id,
            buyer_id,
            service_type,
            product_id: product_id || null,
            quantity: parseInt(quantity),
            frequency: frequency || "daily",
            start_date,
            end_date: end_date || null,
            status: 'active'
        };

        const subscriptionId = await addDoc("subscriptions", subscriptionData);
        res.status(201).json({ message: "Subscription created", subscription_id: subscriptionId });
    } catch (error) {
        console.error("Subscription create error:", error);
        res.status(500).json({ message: "Server error creating subscription" });
    }
});

// Update subscription status
router.put("/update/:id", async (req, res) => {
    try {
        const { status, quantity, frequency } = req.body;
        const updateData = {};

        if (status) updateData.status = status;
        if (quantity) updateData.quantity = parseInt(quantity);
        if (frequency) updateData.frequency = frequency;

        if (Object.keys(updateData).length === 0) {
            return res.status(400).json({ message: "No fields to update" });
        }

        await updateDoc("subscriptions", req.params.id, updateData);
        res.json({ message: "Subscription updated" });
    } catch (error) {
        console.error("Subscription update error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Delete subscription
router.delete("/:id", async (req, res) => {
    try {
        await deleteDoc("subscriptions", req.params.id);
        res.json({ message: "Subscription cancelled" });
    } catch (error) {
        console.error("Subscription delete error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

module.exports = router;
