const express = require("express");
const router = express.Router();
const { getDocs, addDoc, updateDoc, deleteDoc, queryDocs } = require("../db");
const db = require("../db");

// Get cart items for a buyer
router.get("/:buyer_id", async (req, res) => {
    try {
        const cartItems = await queryDocs("cart", "buyer_id", "==", req.params.buyer_id);

        // Get product and farmer details for each cart item
        const cartWithDetails = await Promise.all(cartItems.map(async (item) => {
            const productDoc = await db.collection("products").doc(item.product_id).get();
            const product = productDoc.exists ? { id: productDoc.id, ...productDoc.data() } : null;

            if (!product) {
                return null;
            }

            const farmerDoc = await db.collection("users").doc(product.farmer_id).get();
            const farmer = farmerDoc.exists ? { id: farmerDoc.id, ...farmerDoc.data() } : null;

            return {
                ...item,
                name: product.name,
                price: product.price,
                image_url: product.image_url,
                available_quantity: product.quantity,
                farmer_name: farmer?.name || null,
                farmer_phone: farmer?.phone || null
            };
        }));

        // Filter out null items (products that don't exist)
        const filteredCart = cartWithDetails.filter(item => item !== null);

        res.json(filteredCart);
    } catch (error) {
        console.error("Cart fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Add to cart
router.post("/add", async (req, res) => {
    try {
        const { buyer_id, product_id, quantity } = req.body;

        if (!buyer_id || !product_id || !quantity) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        // Check if item already in cart
        const existingCart = await queryDocs("cart", "buyer_id", "==", buyer_id);
        const existingItem = existingCart.find(item => item.product_id === product_id);

        if (existingItem) {
            // Update quantity
            const newQuantity = existingItem.quantity + parseInt(quantity);
            await updateDoc("cart", existingItem.id, { quantity: newQuantity });
            res.json({ message: "Cart updated", cart_id: existingItem.id });
        } else {
            // Insert new item
            const cartData = {
                buyer_id,
                product_id,
                quantity: parseInt(quantity)
            };
            const cartId = await addDoc("cart", cartData);
            res.json({ message: "Added to cart", cart_id: cartId });
        }
    } catch (error) {
        console.error("Cart add error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Update cart item quantity
router.put("/update", async (req, res) => {
    try {
        const { cart_id, quantity } = req.body;

        if (!cart_id || !quantity || quantity < 1) {
            return res.status(400).json({ message: "Invalid data" });
        }

        await updateDoc("cart", cart_id, { quantity: parseInt(quantity) });
        res.json({ message: "Cart updated" });
    } catch (error) {
        console.error("Cart update error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Remove from cart
router.delete("/remove/:cart_id", async (req, res) => {
    try {
        await deleteDoc("cart", req.params.cart_id);
        res.json({ message: "Item removed from cart" });
    } catch (error) {
        console.error("Cart remove error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Clear cart
router.delete("/clear/:buyer_id", async (req, res) => {
    try {
        const cartItems = await queryDocs("cart", "buyer_id", "==", req.params.buyer_id);
        const deletePromises = cartItems.map(item => deleteDoc("cart", item.id));
        await Promise.all(deletePromises);
        res.json({ message: "Cart cleared" });
    } catch (error) {
        console.error("Cart clear error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

module.exports = router;
