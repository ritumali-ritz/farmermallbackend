# ⚡ Quick Start - Firebase Setup (5 Minutes)

## 🎯 What You Need to Do

### 1. Create Firebase Project
1. Go to: **https://console.firebase.google.com/**
2. Click **"Add project"**
3. Name it: `farmer-mall`
4. Click through (skip Analytics for now)
5. Wait for project creation

### 2. Enable Firestore
1. Click **"Firestore Database"** in left sidebar
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Choose a location (closest to you)
5. Click **"Enable"**

### 3. Get Service Account Key
1. Click **⚙️ (gear icon)** → **"Project settings"**
2. Go to **"Service accounts"** tab
3. Click **"Generate new private key"**
4. Click **"Generate key"** in popup
5. File downloads automatically

### 4. Save the File
1. **Rename** downloaded file to: `firebase-service-account.json`
2. **Move** it to: `C:\Users\Ritesh\farmer_mall_backend\`
3. Make sure it's in the **root folder** (same folder as `server.js`)

### 5. Install & Test
```bash
npm install
npm start
```

You should see: `✅ Firebase Admin initialized with service account file`

---

## ✅ Done!

Your Firebase is set up. The backend will automatically create collections when you use the API.

---

## 📋 What I Need From You

Please provide:
1. **Firebase Project ID** (you'll see it in Firebase Console)
2. **Location** you chose for Firestore
3. **Any errors** you encounter during setup

Or just confirm:
- ✅ Firebase project created
- ✅ Firestore enabled
- ✅ Service account key downloaded and saved
- ✅ File location: `C:\Users\Ritesh\farmer_mall_backend\firebase-service-account.json`

---

## 🆘 If You Get Stuck

**Error: "Firebase initialization error"**
- Check: Is `firebase-service-account.json` in the root folder?
- Check: File name is exactly `firebase-service-account.json` (not `.txt`)

**Error: "Permission denied"**
- Make sure you chose "test mode" when creating Firestore

**Can't find Service Accounts tab?**
- Make sure you're in Project Settings (gear icon)
- Look for "Service accounts" tab at the top

---

**That's it! Let me know when you've completed these steps or if you need help!** 🚀

