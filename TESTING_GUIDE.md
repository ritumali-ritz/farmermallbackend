# Testing Guide - Running App on Connected Phone

## ✅ Setup Status

### Connected Device:
- **Device**: SM M127G (Samsung)
- **Device ID**: RZ8T10NP9FJ
- **Platform**: Android 13 (API 33)
- **Architecture**: android-arm64

### Flutter Setup:
- ✅ Flutter installed (3.38.1)
- ✅ Android toolchain configured
- ✅ Device detected and connected
- ✅ Dependencies installed

## 🚀 Running the App

### Step 1: Start Backend Server
```bash
node server.js
```
Server should start on:
- `http://localhost:5000`
- `http://10.71.164.111:5000` (network accessible)

### Step 2: Run Flutter App on Phone
```bash
cd farmer_mall_app
flutter run -d RZ8T10NP9FJ
```

Or simply:
```bash
flutter run
```
(Flutter will auto-select the connected device)

## 📱 Testing Checklist

### Backend Server:
- [ ] Server starts without errors
- [ ] Server accessible at http://10.71.164.111:5000
- [ ] Database connection successful
- [ ] All routes working

### Flutter App:
- [ ] App builds successfully
- [ ] App installs on phone
- [ ] App launches without crashes
- [ ] Home screen loads
- [ ] Banners display correctly
- [ ] Products load from API
- [ ] Navigation works
- [ ] Login/Register works
- [ ] Cart functionality works
- [ ] Orders display correctly
- [ ] Chat functionality works

## 🔍 Troubleshooting

### If server doesn't start:
1. Check if port 5000 is already in use
2. Verify database connection in `db.js`
3. Check Node.js is installed: `node --version`
4. Install dependencies: `npm install`

### If app doesn't build:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Check Android SDK is properly configured
4. Accept Android licenses: `flutter doctor --android-licenses`

### If app doesn't connect to server:
1. Verify phone and computer are on same WiFi network
2. Check firewall allows port 5000
3. Verify IP address in `api_service.dart` is correct (10.71.164.111)
4. Test server URL in phone browser: `http://10.71.164.111:5000`

### If banners don't load:
1. Check `banner/` folder has images
2. Verify `/banner-files/` route works
3. Check server logs for errors
4. Verify image URLs in database

## 📊 Current Status

### Backend:
- ✅ Server configured
- ✅ Routes set up
- ✅ Database configured
- ✅ Socket.IO configured

### Frontend:
- ✅ All screens implemented
- ✅ API integration complete
- ✅ Error handling added
- ✅ Banner system fixed

## 🎯 Features to Test

1. **Home Screen**:
   - Banner carousel displays
   - Products grid loads
   - Recent orders section (if logged in)

2. **Authentication**:
   - Register new user
   - Login existing user
   - Logout

3. **Products**:
   - View product list
   - View product details
   - Add to cart
   - Buy now

4. **Cart**:
   - Add items
   - Update quantities
   - Remove items
   - Place order

5. **Orders**:
   - View orders (buyer)
   - View orders (farmer)
   - Update order status (farmer)
   - Cancel order (buyer)

6. **Chat**:
   - Send messages
   - Receive messages
   - View chat history

7. **Banners**:
   - Display from database
   - Fallback to folder images
   - Auto-scroll carousel

## 🔧 Quick Commands

### Check connected devices:
```bash
flutter devices
```

### Run on specific device:
```bash
flutter run -d RZ8T10NP9FJ
```

### Check server status:
```bash
netstat -ano | findstr :5000
```

### View Flutter logs:
```bash
flutter logs
```

### Hot reload (while app is running):
Press `r` in terminal

### Hot restart:
Press `R` in terminal

### Stop app:
Press `q` in terminal

## 📝 Notes

- Make sure phone and computer are on the same WiFi network
- Server IP (10.71.164.111) should match your computer's local IP
- If IP changes, update `api_service.dart` baseUrl
- Keep server running while testing app
- Use hot reload for quick testing during development

