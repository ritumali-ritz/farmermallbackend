# Firebase Migration Guide

This project has been migrated from MySQL to Firebase Firestore.

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Go to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Save the downloaded JSON file as `firebase-service-account.json` in the root directory

**Important:** The `firebase-service-account.json` file is already in `.gitignore` for security.

### 3. Alternative: Environment Variable

Instead of placing the file in the root, you can set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable:

```bash
# Windows PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\your\service-account-key.json"

# Linux/Mac
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
```

### 4. Start the Server

```bash
npm start
```

## Database Collections

The following Firestore collections are used:

- `users` - User accounts (farmers and buyers)
- `products` - Products listed by farmers
- `orders` - Orders placed by buyers
- `cart` - Shopping cart items
- `messages` - Chat messages between farmers and buyers
- `subscriptions` - Subscription services
- `farm_details` - Farm information
- `banners` - Banner images for the app

## Migration Notes

### Removed Files

The following MySQL-related files have been removed or are no longer needed:
- `setup_database.js`
- `setup_database.sql`
- `database_updates.sql`
- `database_updates_banners.sql`
- `fix_database.js`
- `setup_all_tables.js`

### Changes

1. **Database Connection**: Replaced MySQL connection with Firebase Admin SDK
2. **Query Syntax**: All SQL queries have been converted to Firestore operations
3. **Data Types**: Firestore handles data types automatically
4. **Timestamps**: Using Firestore server timestamps instead of MySQL TIMESTAMP

## API Endpoints

All API endpoints remain the same. The migration is transparent to the frontend.

## Troubleshooting

### Firebase Not Initialized

If you see "Firebase initialization error":
1. Make sure `firebase-service-account.json` exists in the root directory
2. Check that the JSON file is valid
3. Verify the service account has Firestore permissions

### Collection Not Found

Firestore creates collections automatically when you first write to them. No manual setup is required.

## Support

For Firebase-related issues, refer to:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)

