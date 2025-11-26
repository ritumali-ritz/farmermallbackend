const express = require("express");
const router = express.Router();
const { getDocs, addDoc, updateDoc, queryDocs } = require("../db");
const db = require("../db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// SECRET KEY for JWT
const JWT_SECRET = "FARMER_MALL_SECRET_KEY"; // you can change this

// REGISTER USER
router.post("/register", async (req, res) => {
    try {
        const { name, email, password, role, phone, address } = req.body;

        if (!name || !email || !password || !role || !address) {
            return res.status(400).json({ message: "All fields are required" });
        }

        if (!["farmer", "buyer"].includes(role)) {
            return res.status(400).json({ message: "Invalid role" });
        }

        // Check if email already exists
        const existingUsers = await queryDocs("users", "email", "==", email);
        if (existingUsers.length > 0) {
            return res.status(409).json({ message: "Email already registered" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const userData = {
            name,
            email,
            password: hashedPassword,
            role,
            phone: phone || null,
            address
        };

        const userId = await addDoc("users", userData);

        return res.status(201).json({ message: "User registered successfully", userId });
    } catch (error) {
        console.error("Register error", error);
        return res.status(500).json({ message: "Unexpected error" });
    }
});

// LOGIN USER
router.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: "Email and password are required" });
        }

        // Find user by email
        const users = await queryDocs("users", "email", "==", email);

        // USER NOT FOUND
        if (users.length === 0) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        const user = users[0];

        try {
            // CHECK PASSWORD
            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) {
                return res.status(401).json({ message: "Invalid email or password" });
            }
        } catch (compareError) {
            console.error("Password comparison failed", compareError);
            return res.status(500).json({ message: "Server error" });
        }

        // CREATE JWT TOKEN
        const token = jwt.sign(
            {
                id: user.id,
                email: user.email,
                role: user.role,
            },
            JWT_SECRET,
            { expiresIn: "7d" }
        );

        return res.json({
            message: "Login successful",
            token: token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                phone: user.phone || null,
                address: user.address || null,
            }
        });
    } catch (error) {
        console.error("Login error", error);
        return res.status(500).json({ message: "Server error" });
    }
});

// UPDATE USER ADDRESS
router.put("/address/:id", async (req, res) => {
    try {
        const userId = req.params.id;
        const { address } = req.body;

        if (!address || !address.trim()) {
            return res.status(400).json({ message: "Address is required" });
        }

        // Check if user exists
        const userDoc = await db.collection("users").doc(userId).get();
        if (!userDoc.exists) {
            return res.status(404).json({ message: "User not found" });
        }

        await updateDoc("users", userId, { address: address.trim() });

        res.json({ message: "Address updated", address: address.trim() });
    } catch (error) {
        console.error("❌ Database Error:", error);
        return res.status(500).json({ message: "Server error" });
    }
});

module.exports = router;
