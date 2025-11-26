const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
// You need to download your Firebase service account key JSON file
// and either:
// 1. Place it in the root directory as 'firebase-service-account.json'
// 2. Or set the GOOGLE_APPLICATION_CREDENTIALS environment variable to point to it
// 3. Or provide the credentials directly in this file (not recommended for production)

let firebaseApp;

try {
    // Priority 1: Try environment variable (for cloud deployment)
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log("✅ Firebase Admin initialized from environment variable");
    }
    // Priority 2: Try service account file (for local development)
    else {
        const serviceAccount = require("./firebase-service-account.json");
        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log("✅ Firebase Admin initialized with service account file");
    }
} catch (error) {
    // Priority 3: Try default credentials (for Google Cloud environments)
    try {
        firebaseApp = admin.initializeApp({
            credential: admin.credential.applicationDefault()
        });
        console.log("✅ Firebase Admin initialized with default credentials");
    } catch (defaultError) {
        console.error("❌ Firebase initialization error:", defaultError.message);
        console.log("📝 Please provide Firebase service account credentials:");
        console.log("   1. Download service account key from Firebase Console");
        console.log("   2. Save it as 'firebase-service-account.json' in the root directory");
        console.log("   3. Or set FIREBASE_SERVICE_ACCOUNT environment variable (for cloud)");
        console.log("   4. Or set GOOGLE_APPLICATION_CREDENTIALS environment variable");
        process.exit(1);
    }
}

const db = admin.firestore();
const auth = admin.auth();

module.exports = { db, auth, admin };

