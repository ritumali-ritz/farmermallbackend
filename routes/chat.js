const express = require("express");
const router = express.Router();
const { getDocs, addDoc, queryDocs } = require("../db");
const db = require("../db");

// Get chat history between two users
router.get("/history/:userId/:otherUserId", async (req, res) => {
    try {
        const { userId, otherUserId } = req.params;

        // Validate that users are farmer-buyer pair
        const user1Doc = await db.collection("users").doc(userId).get();
        const user2Doc = await db.collection("users").doc(otherUserId).get();

        if (!user1Doc.exists || !user2Doc.exists) {
            return res.status(400).json({ message: "Users not found" });
        }

        const user1 = { id: user1Doc.id, ...user1Doc.data() };
        const user2 = { id: user2Doc.id, ...user2Doc.data() };

        const validChat = (user1.role === 'farmer' && user2.role === 'buyer') ||
                         (user1.role === 'buyer' && user2.role === 'farmer');

        if (!validChat) {
            return res.status(403).json({ message: "Chat is only allowed between farmers and buyers" });
        }

        // Get messages between these two users
        const messages1 = await queryDocs("messages", "sender_id", "==", userId);
        const messages2 = await queryDocs("messages", "sender_id", "==", otherUserId);

        // Filter messages where receiver is the other user
        const allMessages = [
            ...messages1.filter(m => m.receiver_id === otherUserId),
            ...messages2.filter(m => m.receiver_id === userId)
        ];

        // Get sender, receiver, and product details
        const messagesWithDetails = await Promise.all(allMessages.map(async (msg) => {
            const senderDoc = await db.collection("users").doc(msg.sender_id).get();
            const receiverDoc = await db.collection("users").doc(msg.receiver_id).get();
            
            const sender = senderDoc.exists ? { id: senderDoc.id, ...senderDoc.data() } : null;
            const receiver = receiverDoc.exists ? { id: receiverDoc.id, ...receiverDoc.data() } : null;

            let product = null;
            if (msg.product_id) {
                const productDoc = await db.collection("products").doc(msg.product_id).get();
                product = productDoc.exists ? { id: productDoc.id, ...productDoc.data() } : null;
            }

            return {
                ...msg,
                sender_name: sender?.name || null,
                receiver_name: receiver?.name || null,
                product_name: product?.name || null,
                product_image: product?.image_url || null
            };
        }));

        // Sort by created_at ascending
        messagesWithDetails.sort((a, b) => {
            const aTime = a.created_at?.toMillis?.() || 0;
            const bTime = b.created_at?.toMillis?.() || 0;
            return aTime - bTime;
        });

        res.json(messagesWithDetails);
    } catch (error) {
        console.error("Chat history error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Get all conversations for a user (only farmer-buyer pairs)
router.get("/conversations/:userId", async (req, res) => {
    try {
        const { userId } = req.params;

        // Get user role
        const userDoc = await db.collection("users").doc(userId).get();
        if (!userDoc.exists) {
            return res.status(404).json({ message: "User not found" });
        }
        const user = { id: userDoc.id, ...userDoc.data() };
        const userRole = user.role;

        // Get all messages where user is sender or receiver
        const sentMessages = await queryDocs("messages", "sender_id", "==", userId);
        const receivedMessages = await queryDocs("messages", "receiver_id", "==", userId);

        // Combine and get unique other users
        const otherUserIds = new Set();
        sentMessages.forEach(msg => {
            if (msg.receiver_id) otherUserIds.add(msg.receiver_id);
        });
        receivedMessages.forEach(msg => {
            if (msg.sender_id) otherUserIds.add(msg.sender_id);
        });

        // Get conversations with other users
        const conversations = await Promise.all(Array.from(otherUserIds).map(async (otherUserId) => {
            const otherUserDoc = await db.collection("users").doc(otherUserId).get();
            if (!otherUserDoc.exists) return null;

            const otherUser = { id: otherUserDoc.id, ...otherUserDoc.data() };

            // Only include if it's a farmer-buyer pair
            if ((userRole === 'farmer' && otherUser.role === 'buyer') ||
                (userRole === 'buyer' && otherUser.role === 'farmer')) {

                // Get last message
                const allMessages = [
                    ...sentMessages.filter(m => m.receiver_id === otherUserId),
                    ...receivedMessages.filter(m => m.sender_id === otherUserId)
                ];

                if (allMessages.length === 0) return null;

                // Sort by created_at descending
                allMessages.sort((a, b) => {
                    const aTime = a.created_at?.toMillis?.() || 0;
                    const bTime = b.created_at?.toMillis?.() || 0;
                    return bTime - aTime;
                });

                const lastMessage = allMessages[0];

                return {
                    other_user_id: otherUserId,
                    other_user_name: otherUser.name,
                    other_user_role: otherUser.role,
                    last_message: lastMessage.message,
                    last_message_time: lastMessage.created_at
                };
            }
            return null;
        }));

        // Filter out nulls and sort by last_message_time
        const filteredConversations = conversations
            .filter(c => c !== null)
            .sort((a, b) => {
                const aTime = a.last_message_time?.toMillis?.() || 0;
                const bTime = b.last_message_time?.toMillis?.() || 0;
                return bTime - aTime;
            });

        res.json(filteredConversations);
    } catch (error) {
        console.error("Conversations error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Save message to database
router.post("/save", async (req, res) => {
    try {
        const { sender_id, receiver_id, message, product_id } = req.body;

        if (!sender_id || !receiver_id || !message) {
            return res.status(400).json({ message: "Missing required fields" });
        }

        // Validate that users are farmer-buyer pair
        const senderDoc = await db.collection("users").doc(sender_id).get();
        const receiverDoc = await db.collection("users").doc(receiver_id).get();

        if (!senderDoc.exists || !receiverDoc.exists) {
            return res.status(400).json({ message: "Users not found" });
        }

        const sender = { id: senderDoc.id, ...senderDoc.data() };
        const receiver = { id: receiverDoc.id, ...receiverDoc.data() };

        const validChat = (sender.role === 'farmer' && receiver.role === 'buyer') ||
                         (sender.role === 'buyer' && receiver.role === 'farmer');

        if (!validChat) {
            return res.status(403).json({ message: "Chat is only allowed between farmers and buyers" });
        }

        const messageData = {
            sender_id,
            receiver_id,
            message,
            product_id: product_id || null
        };

        const messageId = await addDoc("messages", messageData);
        res.json({ message: "Message saved", messageId });
    } catch (error) {
        console.error("Save message error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

module.exports = router;
