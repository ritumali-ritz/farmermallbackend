// Script to get your computer's local IP address
// Run: node get_local_ip.js

const os = require('os');

function getLocalIP() {
    const interfaces = os.networkInterfaces();
    
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            // Skip internal (loopback) and non-IPv4 addresses
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address;
            }
        }
    }
    return 'localhost';
}

const ip = getLocalIP();
console.log("\n=== Your Local IP Address ===\n");
console.log(`IP: ${ip}`);
console.log(`\nUpdate api_service.dart with this IP:`);
console.log(`static String baseUrl = kIsWeb`);
console.log(`    ? 'http://localhost:5000'`);
console.log(`    : 'http://${ip}:5000';`);
console.log("\nMake sure:");
console.log("1. Your computer and phone are on the SAME WiFi/hotspot");
console.log("2. Windows Firewall allows port 5000");
console.log("3. Server is running on port 5000");
console.log("\n");

