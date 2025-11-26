# 📱 Switching to Different Mobile Hotspot - Quick Guide

## ✅ YES, it will work! Just follow these steps:

### Step 1: Connect Both Devices
1. Turn on mobile hotspot on your phone
2. Connect your **laptop** to that hotspot
3. Connect your **phone** (the one you'll install app on) to the same hotspot
4. **Important:** Both must be on the SAME hotspot!

### Step 2: Get New IP Address
```bash
node get_local_ip.js
```
This will show your laptop's IP on the new network (e.g., `192.168.43.1` or similar)

### Step 3: Update Config File
Open: `farmer_mall_app/lib/config.dart`

Change line 16:
```dart
static const String serverIP = 'YOUR_NEW_IP_HERE'; // Change this!
```

Replace `YOUR_NEW_IP_HERE` with the IP from Step 2.

### Step 4: Rebuild APK (if needed)
If you already built the APK, rebuild it:
```bash
cd farmer_mall_app
flutter build apk --release
```

### Step 5: Install on Phone
```bash
flutter install
```
Or manually copy the APK and install.

---

## 🔍 How to Find Your IP on New Network

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" under your WiFi adapter (usually starts with 192.168.x.x)

**Or use the helper:**
```bash
node get_local_ip.js
```

---

## ⚠️ Important Notes

1. **Both devices must be on same network** - laptop and phone on same hotspot
2. **Server must be running** - Keep `node server.js` running on laptop
3. **Firewall** - Windows Firewall might block, allow port 5000 if needed
4. **IP changes** - Every time you switch networks, IP changes, so update config

---

## 🚀 Quick Checklist

When switching hotspots:
- [ ] Laptop connected to new hotspot
- [ ] Phone connected to same hotspot  
- [ ] Run `node get_local_ip.js` to get new IP
- [ ] Update `farmer_mall_app/lib/config.dart` with new IP
- [ ] Rebuild APK: `flutter build apk --release`
- [ ] Install on phone: `flutter install`
- [ ] Start server: `node server.js`
- [ ] Test app connection

---

## 💡 Pro Tip

You can create multiple APKs for different networks, or just rebuild when switching. The config file makes it easy - just change one line!





