// Firebase Firestore Database Connection
// This replaces the MySQL connection

const { db, admin } = require("./firebase-config");

// Helper functions for common database operations

/**
 * Get a document by ID from a collection
 */
const getDoc = async (collection, docId) => {
    try {
        const doc = await db.collection(collection).doc(docId).get();
        if (!doc.exists) {
            return null;
        }
        return { id: doc.id, ...doc.data() };
    } catch (error) {
        console.error(`Error getting document from ${collection}:`, error);
        throw error;
    }
};

/**
 * Get all documents from a collection with optional query
 */
const getDocs = async (collection, queryFn = null) => {
    try {
        let query = db.collection(collection);
        if (queryFn) {
            query = queryFn(query);
        }
        const snapshot = await query.get();
        return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
        console.error(`Error getting documents from ${collection}:`, error);
        throw error;
    }
};

/**
 * Add a document to a collection
 */
const addDoc = async (collection, data) => {
    try {
        const docRef = await db.collection(collection).add({
            ...data,
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        return docRef.id;
    } catch (error) {
        console.error(`Error adding document to ${collection}:`, error);
        throw error;
    }
};

/**
 * Update a document in a collection
 */
const updateDoc = async (collection, docId, data) => {
    try {
        await db.collection(collection).doc(docId).update({
            ...data,
            updated_at: admin.firestore.FieldValue.serverTimestamp()
        });
        return true;
    } catch (error) {
        console.error(`Error updating document in ${collection}:`, error);
        throw error;
    }
};

/**
 * Delete a document from a collection
 */
const deleteDoc = async (collection, docId) => {
    try {
        await db.collection(collection).doc(docId).delete();
        return true;
    } catch (error) {
        console.error(`Error deleting document from ${collection}:`, error);
        throw error;
    }
};

/**
 * Query documents with where clause
 */
const queryDocs = async (collection, field, operator, value) => {
    try {
        const snapshot = await db.collection(collection)
            .where(field, operator, value)
            .get();
        return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
        console.error(`Error querying documents from ${collection}:`, error);
        throw error;
    }
};

/**
 * Batch write operations
 */
const batchWrite = async (operations) => {
    try {
        const batch = db.batch();
        operations.forEach(op => {
            if (op.type === 'set') {
                const ref = db.collection(op.collection).doc(op.id);
                batch.set(ref, op.data);
            } else if (op.type === 'update') {
                const ref = db.collection(op.collection).doc(op.id);
                batch.update(ref, op.data);
            } else if (op.type === 'delete') {
                const ref = db.collection(op.collection).doc(op.id);
                batch.delete(ref);
            }
        });
        await batch.commit();
        return true;
    } catch (error) {
        console.error("Error in batch write:", error);
        throw error;
    }
};

// For backward compatibility, export db directly
module.exports = db;
module.exports.getDoc = getDoc;
module.exports.getDocs = getDocs;
module.exports.addDoc = addDoc;
module.exports.updateDoc = updateDoc;
module.exports.deleteDoc = deleteDoc;
module.exports.queryDocs = queryDocs;
module.exports.batchWrite = batchWrite;
