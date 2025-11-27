const express = require("express");
const router = express.Router();
const { getDocs, addDoc, updateDoc, queryDocs } = require("../db");
const db = require("../db");

// Get Socket.IO instance from server
let io = null;
const setIO = (socketIO) => {
    io = socketIO;
};

// Export setIO function before exporting router
router.setIO = setIO;

// Place order
router.post("/place", async (req, res) => {
    try {
        const { buyer_id, product_id, quantity, farmer_id, total_amount } = req.body;

        if (!buyer_id || !product_id || !quantity || !farmer_id) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        // Get buyer address
        const buyerDoc = await db.collection("users").doc(buyer_id).get();
        if (!buyerDoc.exists) {
            return res.status(500).json({ message: "Buyer not found" });
        }

        const buyer = { id: buyerDoc.id, ...buyerDoc.data() };
        const deliveryAddress = buyer.address;
        if (!deliveryAddress || !deliveryAddress.trim()) {
            return res.status(400).json({ message: "Please add your delivery address in your profile" });
        }

        let finalAmount = total_amount;
        if (!finalAmount) {
            const productDoc = await db.collection("products").doc(product_id).get();
            if (!productDoc.exists) {
                return res.status(500).json({ message: "Product not found" });
            }
            const product = { id: productDoc.id, ...productDoc.data() };
            finalAmount = product.price * quantity;
        }

        const orderData = {
            buyer_id,
            product_id,
            quantity: parseInt(quantity),
            farmer_id,
            total_amount: parseFloat(finalAmount),
            delivery_address: deliveryAddress,
            order_status: 'pending',
            payment_method: 'cash_on_delivery',
            payment_status: 'pending'
        };

        const orderId = await addDoc("orders", orderData);

        // Get order details with product info for notification
        const orderDoc = await db.collection("orders").doc(orderId).get();
        const productDoc = await db.collection("products").doc(product_id).get();

        if (orderDoc.exists && productDoc.exists && io) {
            const order = { id: orderDoc.id, ...orderDoc.data() };
            const product = { id: productDoc.id, ...productDoc.data() };
            // Reuse buyer object we already have from line 30

            // Send notification to farmer via Socket.IO
            io.emit(`order_notification_${farmer_id}`, {
                type: 'new_order',
                order: {
                    ...order,
                    product_name: product.name,
                    product_image: product.image_url,
                    buyer_name: buyer.name,
                    buyer_phone: buyer.phone
                },
                message: `New order received: ${product.name} x${quantity}`
            });
        }

        res.status(201).json({ message: "Order placed", id: orderId });
    } catch (error) {
        console.error("Place order error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Place order from cart
router.post("/placeFromCart", async (req, res) => {
    try {
        const { buyer_id, cart_items } = req.body;

        if (!buyer_id || !cart_items || !Array.isArray(cart_items) || cart_items.length === 0) {
            return res.status(400).json({ message: "Invalid cart data" });
        }

        // Get buyer address
        const buyerDoc = await db.collection("users").doc(buyer_id).get();
        if (!buyerDoc.exists) {
            return res.status(500).json({ message: "Buyer not found" });
        }

        const buyer = { id: buyerDoc.id, ...buyerDoc.data() };
        const deliveryAddress = buyer.address;
        if (!deliveryAddress || !deliveryAddress.trim()) {
            return res.status(400).json({ message: "Please add your delivery address in your profile" });
        }

        // Get all products at once
        const productIds = cart_items.map(item => item.product_id);
        const allProducts = await getDocs("products");
        const productMap = {};
        allProducts.forEach(p => {
            if (productIds.includes(p.id)) {
                productMap[p.id] = p;
            }
        });

        // Create orders
        const orderPromises = cart_items.map(async (item) => {
            const product = productMap[item.product_id];
            if (!product) {
                throw new Error(`Product ${item.product_id} not found`);
            }

            const total_amount = product.price * item.quantity;
            const orderData = {
                buyer_id,
                product_id: item.product_id,
                quantity: parseInt(item.quantity),
                farmer_id: product.farmer_id,
                total_amount: parseFloat(total_amount),
                delivery_address: deliveryAddress,
                order_status: 'pending',
                payment_method: 'cash_on_delivery',
                payment_status: 'pending'
            };

            const orderId = await addDoc("orders", orderData);

            // Get order details for notification
            const orderDoc = await db.collection("orders").doc(orderId).get();
            const buyerDoc = await db.collection("users").doc(buyer_id).get();

            if (orderDoc.exists && buyerDoc.exists && io) {
                const order = { id: orderDoc.id, ...orderDoc.data() };
                const buyer = { id: buyerDoc.id, ...buyerDoc.data() };

                // Send notification to farmer via Socket.IO
                io.emit(`order_notification_${product.farmer_id}`, {
                    type: 'new_order',
                    order: {
                        ...order,
                        product_name: product.name,
                        product_image: product.image_url,
                        buyer_name: buyer.name,
                        buyer_phone: buyer.phone
                    },
                    message: `New order received: ${product.name} x${item.quantity}`
                });
            }

            return orderId;
        });

        const orderIds = await Promise.all(orderPromises);

        // Clear cart after successful order
        const cartItems = await queryDocs("cart", "buyer_id", "==", buyer_id);
        const deletePromises = cartItems.map(item => db.collection("cart").doc(item.id).delete());
        await Promise.all(deletePromises);

        res.status(201).json({ message: "Orders placed", order_ids: orderIds });
    } catch (error) {
        console.error("Order from cart error:", error);
        res.status(500).json({ message: "Failed to place orders" });
    }
});

// Get buyer orders
router.get("/buyer/:buyer_id", async (req, res) => {
    try {
        const orders = await queryDocs("orders", "buyer_id", "==", req.params.buyer_id);

        // Get product and farmer details for each order
        const ordersWithDetails = await Promise.all(orders.map(async (order) => {
            const productDoc = await db.collection("products").doc(order.product_id).get();
            const farmerDoc = await db.collection("users").doc(order.farmer_id).get();

            const product = productDoc.exists ? { id: productDoc.id, ...productDoc.data() } : null;
            const farmer = farmerDoc.exists ? { id: farmerDoc.id, ...farmerDoc.data() } : null;

            return {
                ...order,
                product_name: product?.name || null,
                product_image: product?.image_url || null,
                product_price: product?.price || null,
                farmer_name: farmer?.name || null
            };
        }));

        // Sort by created_at descending
        ordersWithDetails.sort((a, b) => {
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return bTime - aTime;
        });

        res.json(ordersWithDetails);
    } catch (error) {
        console.error("Get buyer orders error:", error);
        res.status(500).json({ error: error.message });
    }
});

// Get farmer orders
router.get("/farmer/:farmer_id", async (req, res) => {
    try {
        const orders = await queryDocs("orders", "farmer_id", "==", req.params.farmer_id);

        // Get product and buyer details for each order
        const ordersWithDetails = await Promise.all(orders.map(async (order) => {
            const productDoc = await db.collection("products").doc(order.product_id).get();
            const buyerDoc = await db.collection("users").doc(order.buyer_id).get();

            const product = productDoc.exists ? { id: productDoc.id, ...productDoc.data() } : null;
            const buyer = buyerDoc.exists ? { id: buyerDoc.id, ...buyerDoc.data() } : null;

            return {
                ...order,
                product_name: product?.name || null,
                product_image: product?.image_url || null,
                product_price: product?.price || null,
                buyer_name: buyer?.name || null,
                buyer_phone: buyer?.phone || null,
                buyer_address: buyer?.address || null
            };
        }));

        // Sort by created_at descending
        ordersWithDetails.sort((a, b) => {
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return bTime - aTime;
        });

        res.json(ordersWithDetails);
    } catch (error) {
        console.error("Get farmer orders error:", error);
        res.status(500).json({ error: error.message });
    }
});

// Update order status (for farmer: confirm, ship, mark delivered, cancel)
router.put("/updateStatus/:order_id", async (req, res) => {
    try {
        const { order_status } = req.body;
        const order_id = req.params.order_id;

        const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
        if (!order_status || !validStatuses.includes(order_status)) {
            return res.status(400).json({ message: "Invalid order status" });
        }

        const orderDoc = await db.collection("orders").doc(order_id).get();
        if (!orderDoc.exists) {
            return res.status(404).json({ message: "Order not found" });
        }

        await updateDoc("orders", order_id, { order_status });

        // Get order details for notification
        const order = { id: orderDoc.id, ...orderDoc.data() };
        const productDoc = await db.collection("products").doc(order.product_id).get();
        const buyerDoc = await db.collection("users").doc(order.buyer_id).get();

        if (productDoc.exists && buyerDoc.exists && io) {
            const product = { id: productDoc.id, ...productDoc.data() };
            const buyer = { id: buyerDoc.id, ...buyerDoc.data() };

            // Notify buyer about status change
            io.emit(`order_status_update_${order.buyer_id}`, {
                type: 'order_status_update',
                order_id: order_id,
                order_status: order_status,
                message: `Your order status has been updated to: ${order_status}`
            });
        }

        res.json({ message: "Order status updated successfully", order_status });
    } catch (error) {
        console.error("Update order status error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Cancel order (for buyer)
router.put("/cancel/:order_id", async (req, res) => {
    try {
        const { buyer_id } = req.body;
        const order_id = req.params.order_id;

        if (!buyer_id) {
            return res.status(400).json({ message: "Buyer ID required" });
        }

        // Check if order belongs to buyer and is cancellable
        const orderDoc = await db.collection("orders").doc(order_id).get();
        if (!orderDoc.exists) {
            return res.status(404).json({ message: "Order not found" });
        }

        const order = { id: orderDoc.id, ...orderDoc.data() };
        if (order.buyer_id !== buyer_id) {
            return res.status(403).json({ message: "Order does not belong to this buyer" });
        }

        // Only allow cancellation if order is pending or confirmed
        if (order.order_status === 'shipped' || order.order_status === 'delivered') {
            return res.status(400).json({ message: "Cannot cancel order that is already shipped or delivered" });
        }

        if (order.order_status === 'cancelled') {
            return res.status(400).json({ message: "Order is already cancelled" });
        }

        await updateDoc("orders", order_id, { order_status: 'cancelled' });

        // Notify farmer about cancellation
        if (io) {
            io.emit(`order_status_update_${order.farmer_id}`, {
                type: 'order_cancelled',
                order_id: order_id,
                message: `Order #${order_id} has been cancelled by buyer`
            });
        }

        res.json({ message: "Order cancelled successfully" });
    } catch (error) {
        console.error("Cancel order error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Update payment status (mark as paid on delivery)
router.put("/updatePayment/:order_id", async (req, res) => {
    try {
        const { payment_status } = req.body;
        const order_id = req.params.order_id;

        const validStatuses = ['pending', 'paid', 'failed'];
        if (!payment_status || !validStatuses.includes(payment_status)) {
            return res.status(400).json({ message: "Invalid payment status" });
        }

        const orderDoc = await db.collection("orders").doc(order_id).get();
        if (!orderDoc.exists) {
            return res.status(404).json({ message: "Order not found" });
        }

        await updateDoc("orders", order_id, { payment_status });

        res.json({ message: "Payment status updated successfully", payment_status });
    } catch (error) {
        console.error("Update payment status error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Export router (setIO is already attached to it)
module.exports = router;
