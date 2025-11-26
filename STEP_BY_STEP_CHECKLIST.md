# ✅ Step-by-Step Checklist

Use this checklist to track your progress. Check off each step as you complete it.

## PART 1: Firebase Setup 🔥

### Account & Project
- [ ] Step 1.1: Opened Firebase Console (https://console.firebase.google.com/)
- [ ] Step 1.2: Created new project named "farmer-mall"
- [ ] Step 1.3: Skipped Google Analytics
- [ ] Step 1.4: Project created successfully

### Firestore Database
- [ ] Step 2.1: Opened Firestore Database
- [ ] Step 2.2: Selected "Start in test mode"
- [ ] Step 2.3: Chose location (e.g., asia-south1)
- [ ] Step 2.4: Firestore enabled

### Service Account Key
- [ ] Step 3.1: Went to Project Settings
- [ ] Step 3.2: Opened Service Accounts tab
- [ ] Step 3.3: Generated new private key
- [ ] Step 3.4: Renamed file to `firebase-service-account.json`
- [ ] Step 3.5: Moved file to project root folder

### Local Testing
- [ ] Step 4.1: Ran `npm install` (successful)
- [ ] Step 4.2: Ran `npm start` (server started)
- [ ] Step 4.3: Saw "✅ Firebase Admin initialized" message
- [ ] Step 4.4: Tested http://localhost:5000/ (works)
- [ ] Step 4.5: Tested registration (optional - data appears in Firestore)

**✅ PART 1 COMPLETE:** Firebase is set up and working locally!

---

## PART 2: Prepare for Deployment 📦

### GitHub Setup
- [ ] Step 5.1: Created GitHub account (or already have one)
- [ ] Step 5.2: Created new repository "farmer-mall-backend"
- [ ] Step 5.3: Initialized git in project folder
- [ ] Step 5.4: Added all files and committed
- [ ] Step 5.5: Pushed code to GitHub

### Environment Variables
- [ ] Step 6.1: Opened `firebase-service-account.json`
- [ ] Step 6.2: Copied entire JSON content

**✅ PART 2 COMPLETE:** Code is on GitHub, ready for deployment!

---

## PART 3: Deploy to Render ☁️

### Render Account
- [ ] Step 7.1: Opened render.com
- [ ] Step 7.2: Signed up with GitHub

### Create Web Service
- [ ] Step 8.1: Clicked "New +" → "Web Service"
- [ ] Step 8.2: Connected GitHub repository
- [ ] Step 8.3: Configured service:
  - [ ] Name: farmer-mall-backend
  - [ ] Runtime: Node
  - [ ] Build Command: npm install
  - [ ] Start Command: npm start
  - [ ] Plan: Free
- [ ] Step 8.4: Added environment variables:
  - [ ] NODE_ENV = production
  - [ ] PORT = 5000
  - [ ] FIREBASE_SERVICE_ACCOUNT = (pasted JSON)
- [ ] Step 8.5: Clicked "Create Web Service"

### Deployment
- [ ] Step 9.1: Monitored build process
- [ ] Step 9.2: Build successful
- [ ] Step 9.3: Got deployment URL

### Test Deployment
- [ ] Step 10.1: Tested URL in browser (works)
- [ ] Step 10.2: Tested API endpoint (optional)

**✅ PART 3 COMPLETE:** Backend is live on Render!

---

## PART 4: Update Flutter App 📱

### Update Configuration
- [ ] Step 11.1: Opened `farmer_mall_app/lib/config.dart`
- [ ] Step 11.2: Updated with Render URL
- [ ] Step 11.3: Set `isProduction = true`

### Rebuild App
- [ ] Step 12.1: Ran `flutter clean`
- [ ] Step 12.2: Ran `flutter pub get`
- [ ] Step 12.3: Built APK or ran app

### Test App
- [ ] Step 13.1: Installed app on device
- [ ] Step 13.2: Tested registration
- [ ] Step 13.3: Tested login
- [ ] Step 13.4: Tested other features

**✅ PART 4 COMPLETE:** App works from anywhere!

---

## 🎉 ALL DONE!

- [ ] Everything works!
- [ ] App accessible from anywhere
- [ ] Backend running on cloud
- [ ] Firebase connected
- [ ] Ready to use!

---

## 📝 Notes

Write down important information here:

**Firebase Project ID:** _______________________

**Render URL:** _______________________

**GitHub Repository:** _______________________

**Any issues encountered:** 
- 

---

**If you get stuck, note which step and ask for help!**

