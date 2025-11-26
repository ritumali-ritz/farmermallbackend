# Network Setup & APK Build Guide

## 📱 Your Questions Answered

### 1. **Will app work if connected to different hotspot?**

**Answer: YES, but you need to update the IP address!**

When you change networks (different WiFi/hotspot), your computer gets a new IP address. The app currently has a hardcoded IP (`10.71.164.111`), so you need to update it.

**Solution:**
1. Run `node get_local_ip.js` to get your new IP
2. Update `farmer_mall_app/lib/services/api_service.dart` with the new IP
3. Rebuild the app

**Better Solution (Dynamic IP):**
I've created a helper script. See "Dynamic IP Setup" below.

---

### 2. **How to Get Farmer ID?**

**Method 1: From Database (Recommended)**
```bash
node get_farmer_id.js
```
This will show all farmers with their IDs.

**Method 2: From App After Login**
1. Login as farmer in the app
2. Go to Profile screen
3. Your ID is stored in `current_user` (it's the `id` field)

**Method 3: From Database Query**
```sql
SELECT id, name, email FROM users WHERE role = 'farmer';
```

**To use in Farmer Dashboard Web:**
```
farmer_dashboard_web/index.html?farmer_id=YOUR_ID
```

---

### 3. **How to Build Installable APK?**

#### Prerequisites:
- Flutter SDK installed
- Android Studio installed
- Android device connected OR emulator running

#### Steps:

**Step 1: Fix IP Address First**
```bash
# Get your current IP
node get_local_ip.js

# Update api_service.dart with the IP
# Edit: farmer_mall_app/lib/services/api_service.dart
# Change line 14 to your IP
```

**Step 2: Navigate to Flutter App**
```bash
cd farmer_mall_app
```

**Step 3: Get Dependencies**
```bash
flutter pub get
```

**Step 4: Check for Connected Devices**
```bash
flutter devices
```
You should see your device listed.

**Step 5: Build APK**
```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution - smaller, optimized)
flutter build apk --release
```

**Step 6: Find Your APK**
- Debug APK: `farmer_mall_app/build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `farmer_mall_app/build/app/outputs/flutter-apk/app-release.apk`

**Step 7: Install on Device**
```bash
# Option 1: Install directly via Flutter
flutter install

# Option 2: Install manually
# Copy APK to phone and install
# Or use: adb install app-release.apk
```

---

### 4. **How to Run on Connected Device?**

**Method 1: Direct Run (Recommended)**
```bash
cd farmer_mall_app
flutter run
```
Flutter will detect your connected device and install the app automatically.

**Method 2: Select Device**
```bash
flutter devices  # List all devices
flutter run -d <device-id>  # Run on specific device
```

**Method 3: Install APK Manually**
1. Build APK (see above)
2. Copy APK to phone
3. Enable "Install from Unknown Sources" on Android
4. Tap APK to install

---

## 🔧 Dynamic IP Setup (Recommended)

Instead of hardcoding IP, you can make it easier:

### Option A: Use Environment Variable
1. Create `.env` file in `farmer_mall_app/`:
```
API_BASE_URL=http://YOUR_IP:5000
```

2. Use `flutter_dotenv` package (add to pubspec.yaml):
```yaml
dependencies:
  flutter_dotenv: ^5.0.2
```

3. Load in `api_service.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static String baseUrl = kIsWeb
    ? 'http://localhost:5000'
    : dotenv.env['API_BASE_URL'] ?? 'http://10.71.164.111:5000';
```

### Option B: Simple Config File (Easier)
Create `farmer_mall_app/lib/config.dart`:
```dart
class AppConfig {
  // Change this IP when you change networks
  static const String serverIP = '10.71.164.111'; // Update this!
  static const int serverPort = 5000;
  
  static String get baseUrl => kIsWeb
      ? 'http://localhost:$serverPort'
      : 'http://$serverIP:$serverPort';
}
```

Then in `api_service.dart`:
```dart
import 'config.dart';
static String baseUrl = AppConfig.baseUrl;
```

---

## 🌐 Network Troubleshooting

### Problem: App can't connect to server

**Checklist:**
1. ✅ Computer and phone on SAME WiFi/hotspot
2. ✅ Server is running (`node server.js`)
3. ✅ IP address is correct (run `node get_local_ip.js`)
4. ✅ Windows Firewall allows port 5000
5. ✅ No VPN interfering

### Allow Firewall (Windows):
```powershell
# Run PowerShell as Administrator
New-NetFirewallRule -DisplayName "Farmer Mall Server" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

### Test Connection:
```bash
# From phone browser, try:
http://YOUR_IP:5000

# Should see: {"status":"ok","message":"Farmer Mall API running"}
```

---

## 📦 Building Release APK (For Distribution)

### Step 1: Configure Signing (Optional but Recommended)

Create `farmer_mall_app/android/key.properties`:
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=farmer_mall
storeFile=../farmer_mall.jks
```

### Step 2: Update build.gradle

Edit `farmer_mall_app/android/app/build.gradle.kts`:
```kotlin
android {
    ...
    signingConfigs {
        create("release") {
            // Add signing config if you have a keystore
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true
            shrinkResources = true
        }
    }
}
```

### Step 3: Build Release APK
```bash
cd farmer_mall_app
flutter build apk --release
```

### Step 4: Build App Bundle (For Play Store)
```bash
flutter build appbundle --release
```

---

## 🚀 Quick Start Checklist

Before building APK:
- [ ] Update IP address in `api_service.dart`
- [ ] Run `flutter pub get`
- [ ] Test app with `flutter run`
- [ ] Fix any errors
- [ ] Build APK with `flutter build apk --release`

---

## 📝 Common Issues

### Issue: "No devices found"
**Solution:**
- Enable USB debugging on Android
- Install ADB drivers
- Run `flutter doctor` to check setup

### Issue: "Gradle build failed"
**Solution:**
```bash
cd farmer_mall_app/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Issue: "Connection refused"
**Solution:**
- Check server is running
- Verify IP address
- Check firewall settings
- Ensure same network

---

## 🎯 Summary

1. **Different Network?** → Update IP in `api_service.dart`
2. **Get Farmer ID?** → Run `node get_farmer_id.js`
3. **Build APK?** → `flutter build apk --release`
4. **Run on Device?** → `flutter run` or install APK manually

---

## 📞 Need Help?

- Check Flutter docs: https://flutter.dev/docs
- Check server logs: Look at terminal running `node server.js`
- Test API: Use Postman or browser to test endpoints

