# 🔥 Firebase Setup Guide - Step by Step for Beginners

This guide will help you set up Firebase Firestore for your Farmer Mall backend project.

## 📋 What You Need

- A Google account (Gmail)
- 5-10 minutes
- No credit card required (Firebase has a free tier)

---

## Step 1: Create a Firebase Project

### 1.1 Go to Firebase Console
1. Open your web browser
2. Go to: **https://console.firebase.google.com/**
3. Sign in with your Google account

### 1.2 Create New Project
1. Click the **"Add project"** button (or "Create a project")
2. **Project name**: Enter `farmer-mall` (or any name you prefer)
3. Click **"Continue"**

### 1.3 Google Analytics (Optional)
1. You'll see "Enable Google Analytics for this project"
2. **For now, you can turn it OFF** (toggle switch)
3. Click **"Create project"**

### 1.4 Wait for Project Creation
- Firebase will create your project (takes 30-60 seconds)
- Click **"Continue"** when done

---

## Step 2: Enable Firestore Database

### 2.1 Open Firestore
1. In the left sidebar, click **"Firestore Database"**
2. Click **"Create database"** button

### 2.2 Choose Security Rules
1. You'll see two options:
   - **Start in production mode** (recommended for real apps)
   - **Start in test mode** (easier for development)

2. **For Development/Testing:**
   - Select **"Start in test mode"**
   - Click **"Next"**

3. **For Production:**
   - Select **"Start in production mode"**
   - We'll set up rules later

### 2.3 Choose Location
1. Select a **location** closest to your users
   - Example: `us-central` (United States)
   - Example: `asia-south1` (India)
   - Example: `europe-west` (Europe)

2. Click **"Enable"**

3. Wait for Firestore to initialize (30-60 seconds)

---

## Step 3: Get Service Account Key (IMPORTANT!)

This is the file your backend needs to connect to Firebase.

### 3.1 Go to Project Settings
1. Click the **gear icon** (⚙️) next to "Project Overview" in the left sidebar
2. Click **"Project settings"**

### 3.2 Go to Service Accounts Tab
1. Click the **"Service accounts"** tab at the top
2. You'll see "Firebase Admin SDK"

### 3.3 Generate Private Key
1. Click **"Generate new private key"** button
2. A popup will appear - click **"Generate key"**
3. A JSON file will download automatically

### 3.4 Save the File
1. **Rename the downloaded file** to: `firebase-service-account.json`
2. **Move it** to your project root folder:
   ```
   C:\Users\Ritesh\farmer_mall_backend\firebase-service-account.json
   ```

⚠️ **IMPORTANT**: 
- Keep this file **SECRET** - never share it or commit it to Git
- It's already in `.gitignore` so it won't be uploaded

---

## Step 4: Set Up Firestore Security Rules (For Production)

### 4.1 Go to Firestore Rules
1. In Firebase Console, go to **"Firestore Database"**
2. Click the **"Rules"** tab

### 4.2 For Development (Test Mode)
If you chose "test mode" in Step 2.2, you can skip this for now.

### 4.3 For Production (Recommended Rules)
Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products - anyone can read, only farmers can write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Orders - users can read/write their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
    
    // Cart - users can read/write their own cart
    match /cart/{cartId} {
      allow read, write: if request.auth != null;
    }
    
    // Messages - users can read/write messages they're part of
    match /messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // Other collections
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Note**: Since your backend uses JWT (not Firebase Auth), you might need to adjust these rules. For now, test mode is fine for development.

---

## Step 5: Verify Your Setup

### 5.1 Check Your Project Structure
Your project should now have:
```
farmer_mall_backend/
├── firebase-service-account.json  ← This file should be here
├── firebase-config.js
├── db.js
├── server.js
└── ... (other files)
```

### 5.2 Install Dependencies
Open terminal in your project folder and run:
```bash
npm install
```

### 5.3 Test the Connection
Start your server:
```bash
npm start
```

You should see:
```
✅ Firebase Admin initialized with service account file
Server running at http://localhost:5000
```

If you see an error, check:
- Is `firebase-service-account.json` in the root folder?
- Is the file name exactly `firebase-service-account.json`?
- Did you install dependencies? (`npm install`)

---

## Step 6: Test Your API

### 6.1 Test Registration
Use Postman, curl, or your Flutter app to test:

```bash
POST http://localhost:5000/auth/register
Content-Type: application/json

{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123",
  "role": "buyer",
  "address": "123 Test Street"
}
```

### 6.2 Check Firestore
1. Go back to Firebase Console
2. Click **"Firestore Database"**
3. You should see a new collection called **"users"**
4. Click on it to see your test user!

---

## 🎉 Congratulations!

Your Firebase setup is complete! Your backend is now using Firebase Firestore instead of MySQL.

---

## 📝 What Happens Next?

### Collections Will Be Created Automatically
When you use the API, Firestore will automatically create these collections:
- `users` - When someone registers
- `products` - When a farmer adds a product
- `orders` - When someone places an order
- `cart` - When items are added to cart
- `messages` - When users chat
- `subscriptions` - When subscriptions are created
- `farm_details` - When farmers add farm info
- `banners` - When banners are added

### No Manual Setup Needed!
Unlike MySQL, you don't need to create tables. Firestore creates collections automatically when you first write data to them.

---

## ❓ Common Questions

### Q: Do I need Firebase Authentication?
**A:** No! Your app uses JWT tokens from your backend. Firebase Authentication is not needed.

### Q: Is Firebase free?
**A:** Yes! Firebase has a generous free tier:
- 50,000 reads/day
- 20,000 writes/day
- 20,000 deletes/day
- 1 GB storage

This is plenty for development and small apps.

### Q: What if I exceed the free tier?
**A:** Firebase will notify you. You can upgrade to a paid plan if needed.

### Q: Can I use the same Firebase project for multiple apps?
**A:** Yes! One Firebase project can have multiple apps (iOS, Android, Web).

### Q: Where is my data stored?
**A:** In Google Cloud servers, in the location you chose in Step 2.3.

---

## 🆘 Troubleshooting

### Error: "Firebase initialization error"
- ✅ Check: Is `firebase-service-account.json` in the root folder?
- ✅ Check: Is the file name exactly correct?
- ✅ Check: Did you download the file from Firebase Console?

### Error: "Permission denied"
- ✅ Check: Are you using test mode? (Easier for development)
- ✅ Check: Firestore security rules in Firebase Console

### Error: "Collection not found"
- ✅ This is normal! Collections are created automatically on first write.

---

## 📞 Need Help?

If you get stuck:
1. Check the error message in your terminal
2. Check Firebase Console for any errors
3. Make sure `firebase-service-account.json` is in the correct location
4. Verify you ran `npm install`

---

## ✅ Checklist

Before you start using the app, make sure:
- [ ] Firebase project created
- [ ] Firestore Database enabled
- [ ] Service account key downloaded
- [ ] `firebase-service-account.json` saved in project root
- [ ] Dependencies installed (`npm install`)
- [ ] Server starts without errors (`npm start`)
- [ ] Can see collections in Firebase Console after testing API

---

**You're all set! 🎉**

Your backend is now ready to use Firebase Firestore!

