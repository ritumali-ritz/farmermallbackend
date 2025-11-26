# Quick Start Guide - Run App on Your Phone

## 🚀 Quick Start (2 Steps)

### Step 1: Start Backend Server
Open a **new terminal/PowerShell window** and run:
```powershell
cd C:\Users\Ritesh\farmer_mall_backend
node server.js
```

You should see:
```
Connected to MySQL Database
Server running at http://localhost:5000
Server accessible on network at http://10.71.164.111:5000
```

**Keep this terminal open!** The server must stay running.

### Step 2: Run Flutter App on Your Phone
Open **another terminal/PowerShell window** and run:
```powershell
cd C:\Users\Ritesh\farmer_mall_backend\farmer_mall_app
flutter run -d RZ8T10NP9FJ
```

Or simply:
```powershell
flutter run
```

The app will:
1. Build the APK
2. Install on your phone (SM M127G)
3. Launch automatically
4. Connect to the backend server

## ✅ What to Expect

1. **First Run**: Takes 2-5 minutes (building APK)
2. **Subsequent Runs**: Much faster (hot reload)
3. **App Opens**: Home screen with banners and products
4. **Connection**: App connects to server at `http://10.71.164.111:5000`

## 🔍 Verify Everything Works

### Check Server is Running:
- Open browser on phone: `http://10.71.164.111:5000`
- Should see: `{"status":"ok","message":"Farmer Mall API running"}`

### Check App Features:
- ✅ Home screen loads
- ✅ Banners display (from banner folder)
- ✅ Products show in grid
- ✅ Can browse without login
- ✅ Can login/register
- ✅ Can add to cart
- ✅ Can place orders

## 🛠️ Troubleshooting

### Server won't start:
```powershell
# Check if port is in use
netstat -ano | findstr :5000

# If something is using port 5000, kill it or change PORT in server.js
```

### App won't build:
```powershell
cd farmer_mall_app
flutter clean
flutter pub get
flutter run
```

### App can't connect to server:
1. Make sure phone and computer are on **same WiFi**
2. Check computer's IP: `ipconfig` (should be 10.71.164.111)
3. If IP changed, update `farmer_mall_app/lib/services/api_service.dart`
4. Test in phone browser: `http://10.71.164.111:5000`

### Banners don't show:
- Check `banner/` folder has images
- Check server logs for errors
- Banners should auto-load from folder if database is empty

## 📱 Your Device Info

- **Device**: SM M127G (Samsung)
- **ID**: RZ8T10NP9FJ
- **Android**: 13 (API 33)
- **Status**: ✅ Connected and Ready

## 🎯 Testing Tips

1. **Hot Reload**: While app is running, press `r` in terminal to reload
2. **Hot Restart**: Press `R` to restart app
3. **Stop App**: Press `q` to quit
4. **View Logs**: Check terminal for Flutter logs

## 📝 Important Notes

- **Keep server running** while testing app
- **Same WiFi network** required for phone-computer connection
- **First build** takes time, be patient
- **Hot reload** works great for quick testing

## ✅ Success Indicators

When everything works:
- ✅ Server shows "Server running at http://localhost:5000"
- ✅ Flutter shows "Running on SM M127G"
- ✅ App opens on your phone
- ✅ Home screen shows banners and products
- ✅ No connection errors in logs

Good luck! 🚀

