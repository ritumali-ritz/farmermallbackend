const express = require("express");
const cors = require("cors");
const http = require("http");
const socketIO = require("socket.io");

const authRoutes = require("./routes/auth");
const farmerRoutes = require("./routes/farmer");
const buyerRoutes = require("./routes/buyer");
const orderRoutes = require("./routes/order");
const uploadRoutes = require("./routes/upload");
const chatRoutes = require("./routes/chat");
const cartRoutes = require("./routes/cart");
const subscriptionRoutes = require("./routes/subscription");
const farmRoutes = require("./routes/farm");
const adminRoutes = require("./routes/admin");
const { addDoc } = require("./db");
const db = require("./db");

const PORT = process.env.PORT || 5000;
const app = express();

app.use(cors());
app.use(express.json());
// Serve uploaded files statically
app.use("/uploads", express.static("uploads"));
// Serve product images statically
app.use("/images", express.static("images"));
// Serve curated banner assets (banner/ folder)
app.use("/banner-files", express.static("banner"));

// ROUTES
app.use("/auth", authRoutes);
app.use("/farmer", farmerRoutes);
app.use("/buyer", buyerRoutes);
app.use("/order", orderRoutes);

app.use("/upload", uploadRoutes);
app.use("/chat", chatRoutes);
app.use("/cart", cartRoutes);
app.use("/subscription", subscriptionRoutes);
app.use("/farm", farmRoutes);
app.use("/admin", adminRoutes);
app.use("/banner", require("./routes/banner"));

const server = http.createServer(app);

const io = socketIO(server, {
    cors: { origin: "*" }
});

// Pass io instance to order routes for notifications
if (typeof orderRoutes.setIO === 'function') {
    orderRoutes.setIO(io);
} else {
    console.warn('Warning: orderRoutes.setIO is not available');
}

// Store active users
const activeUsers = new Map();

io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    // User joins with their user ID
    socket.on("join", (userId) => {
        activeUsers.set(userId, socket.id);
        socket.userId = userId;
        console.log(`User ${userId} joined chat`);
    });

    // Send message
    socket.on("send_message", async (data) => {
        const { receiver_id, message, product_id } = data;
        const sender_id = socket.userId;

        if (!sender_id || !receiver_id) {
            socket.emit("message_error", { error: "Invalid sender or receiver" });
            return;
        }

        try {
            // Validate chat: only farmer-buyer pairs can chat
            const senderDoc = await db.collection("users").doc(sender_id).get();
            const receiverDoc = await db.collection("users").doc(receiver_id).get();

            if (!senderDoc.exists || !receiverDoc.exists) {
                socket.emit("message_error", { error: "Users not found" });
                return;
            }

            const sender = { id: senderDoc.id, ...senderDoc.data() };
            const receiver = { id: receiverDoc.id, ...receiverDoc.data() };

            // Check if one is farmer and other is buyer
            const validChat = (sender.role === 'farmer' && receiver.role === 'buyer') ||
                            (sender.role === 'buyer' && receiver.role === 'farmer');

            if (!validChat) {
                socket.emit("message_error", { error: "Chat is only allowed between farmers and buyers" });
                return;
            }

            // Save to database
            const messageData = {
                sender_id: sender_id,
                receiver_id: receiver_id,
                message: message,
                product_id: product_id || null
            };

            const messageId = await addDoc("messages", messageData);

            const fullMessageData = {
                id: messageId,
                sender_id: sender_id,
                receiver_id: receiver_id,
                message: message,
                product_id: product_id || null,
                sender_name: sender.name,
                created_at: new Date(),
            };

            // Send to receiver if online
            const receiverSocketId = activeUsers.get(receiver_id);
            if (receiverSocketId) {
                io.to(receiverSocketId).emit("receive_message", fullMessageData);
            }

            // Confirm to sender
            socket.emit("message_sent", fullMessageData);
        } catch (error) {
            console.error("Error saving message:", error);
            socket.emit("message_error", { error: "Failed to save message" });
        }
    });

    socket.on("disconnect", () => {
        if (socket.userId) {
            activeUsers.delete(socket.userId);
            console.log(`User ${socket.userId} disconnected`);
        }
    });
});

app.get("/", (_req, res) => {
    res.json({ status: "ok", message: "Farmer Mall API running" });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running at http://localhost:${PORT}`);
    console.log(`Server accessible on network at http://10.71.164.111:${PORT}`);
});
