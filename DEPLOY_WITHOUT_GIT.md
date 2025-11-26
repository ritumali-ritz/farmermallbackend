# 🚀 Deploy to Render Without GitHub

## Alternative Method: Direct Upload

If you don't want to install Git, we can deploy directly to Render!

---

## Step 1: Prepare Your Project

### Create a ZIP File

1. **Select all files** in your project folder:
   - Go to: `C:\Users\Ritesh\farmer_mall_backend`
   - Select all files (Ctrl+A)
   - **EXCEPT**: Don't include `node_modules` folder (if it exists)
   - **EXCEPT**: Don't include `firebase-service-account.json` (we'll add it as environment variable)

2. **Right-click** → **"Send to"** → **"Compressed (zipped) folder"**
3. Name it: `farmer-mall-backend.zip`

---

## Step 2: Sign Up for Render

1. Go to: **https://render.com/**
2. Click **"Get Started for Free"**
3. Sign up with email (no GitHub needed!)

---

## Step 3: Create Web Service

1. In Render, click **"New +"** → **"Web Service"**
2. Click **"Public Git repository"** or look for **"Manual Deploy"** option
3. If you see **"Upload ZIP"** or **"Manual Deploy"**, use that
4. Upload your ZIP file

---

## Step 4: Configure

1. **Name**: `farmer-mall-backend`
2. **Environment**: `Node`
3. **Build Command**: `npm install`
4. **Start Command**: `npm start`

---

## Step 5: Add Environment Variables

1. Go to **"Environment"** tab
2. Add:
   - `NODE_ENV` = `production`
   - `PORT` = `5000`
   - `FIREBASE_SERVICE_ACCOUNT` = (paste your JSON content)

---

## ⚠️ Important Notes

- **Firebase file**: Don't include `firebase-service-account.json` in ZIP
- **Add it as environment variable** instead (safer!)
- **node_modules**: Don't include (Render will install)

---

## 🎯 Ready?

**Tell me:**
1. Do you want to try this method?
2. Or would you prefer to install Git first?

**I can guide you through either way!** 🚀

