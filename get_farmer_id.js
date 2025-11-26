// Helper script to get Farmer ID from database
// Run: node get_farmer_id.js

const db = require("./db");

console.log("\n=== Farmer ID Lookup ===\n");

// Get all farmers
db.query("SELECT id, name, email, phone FROM users WHERE role = 'farmer' ORDER BY id", (err, results) => {
    if (err) {
        console.error("Error:", err.message);
        db.end();
        return;
    }

    if (results.length === 0) {
        console.log("No farmers found in database.");
        console.log("\nTo create a farmer account:");
        console.log("1. Register through the app with role='farmer'");
        console.log("2. Or insert directly into database");
        db.end();
        return;
    }

    console.log("Found Farmers:\n");
    console.log("ID  | Name                | Email");
    console.log("----|---------------------|-------------------");
    
    results.forEach(farmer => {
        const id = String(farmer.id).padEnd(3);
        const name = (farmer.name || '').padEnd(20).substring(0, 20);
        const email = (farmer.email || '').padEnd(18).substring(0, 18);
        console.log(`${id} | ${name} | ${email}`);
    });

    console.log("\n=== How to Use Farmer ID ===\n");
    console.log("1. For Farmer Dashboard Web:");
    console.log("   Open: farmer_dashboard_web/index.html?farmer_id=YOUR_ID");
    console.log("\n2. In the app:");
    console.log("   - Login as farmer");
    console.log("   - Your ID is automatically used");
    console.log("\n3. To check your ID after login:");
    console.log("   - Go to Profile screen in app");
    console.log("   - Your ID is stored there");

    db.end();
});

