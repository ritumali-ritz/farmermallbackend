# 🚀 Quick Start Guide

## ✅ All Your Questions Answered

### 1. **Will app work on different hotspot?**
**YES!** But you need to update the IP address in one place:
- Open: `farmer_mall_app/lib/config.dart`
- Change line 13: `static const String serverIP = 'YOUR_NEW_IP';`
- Get your IP: Run `node get_local_ip.js`

### 2. **How to get Farmer ID?**
**Easiest way:**
```bash
node get_farmer_id.js
```
Shows all farmers with their IDs.

**Or from app:**
- Login as farmer
- Go to Profile screen
- Your ID is stored there

### 3. **Build APK - Easiest Way:**
**Option A: Use the batch file (Windows)**
```bash
BUILD_APK.bat
```
Just double-click and follow prompts!

**Option B: Manual**
```bash
cd farmer_mall_app
flutter pub get
flutter build apk --release
```
APK will be in: `farmer_mall_app/build/app/outputs/flutter-apk/app-release.apk`

### 4. **Run on Connected Device:**
**Option A: Use the batch file**
```bash
RUN_ON_DEVICE.bat
```

**Option B: Manual**
```bash
cd farmer_mall_app
flutter run
```

---

## 📋 Step-by-Step: First Time Setup

### Before Building APK:

1. **Update IP Address**
   ```bash
   node get_local_ip.js
   ```
   Copy the IP shown, then:
   - Open `farmer_mall_app/lib/config.dart`
   - Update `serverIP` on line 13

2. **Start Server**
   ```bash
   node server.js
   ```
   Keep this running!

3. **Connect Your Phone**
   - Connect via USB
   - Enable USB debugging
   - Or connect to same WiFi

4. **Build & Install**
   ```bash
   # Option 1: Use batch file
   BUILD_APK.bat
   
   # Option 2: Manual
   cd farmer_mall_app
   flutter build apk --release
   flutter install
   ```

---

## 🔧 When You Change Networks

1. **Get new IP:**
   ```bash
   node get_local_ip.js
   ```

2. **Update config:**
   - Open `farmer_mall_app/lib/config.dart`
   - Change `serverIP` to new IP

3. **Rebuild app:**
   ```bash
   cd farmer_mall_app
   flutter build apk --release
   ```

4. **Reinstall on phone:**
   ```bash
   flutter install
   ```

---

## 🎯 Common Commands

```bash
# Get your IP address
node get_local_ip.js

# Get farmer IDs
node get_farmer_id.js

# Start server
node server.js

# Build APKll
cd farmer_mall_app
flutter build apk --release

# Run on device
flutter run

# Check connected devices
flutter devices
```

---

## ⚠️ Important Notes

1. **Always update IP when changing networks**
2. **Server must be running** (`node server.js`)
3. **Phone and computer must be on same network**
4. **Windows Firewall** may block port 5000 - allow it if needed

---

## 📱 Testing Checklist

Before building APK:
- [ ] IP address updated in `config.dart`
- [ ] Server is running
- [ ] Tested with `flutter run` first
- [ ] No errors in console
- [ ] App connects to server successfully

---

## 🆘 Troubleshooting

**"Connection refused"**
→ Check IP address, ensure server is running

**"No devices found"**
→ Enable USB debugging, check `flutter devices`

**"Build failed"**
→ Run `flutter clean` then `flutter pub get`

**"Can't connect to server"**
→ Check firewall, ensure same network

---

## 📞 Need More Help?

See `NETWORK_AND_BUILD_GUIDE.md` for detailed instructions.

