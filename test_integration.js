const axios = require('axios');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp({
  storageBucket: 'midi-studio.firebasestorage.app'
});

const db = admin.firestore();
const storage = admin.storage();
const bucket = storage.bucket();

const userId = 'integration-test-user';
const functionUrl = 'https://us-central1-midi-studio.cloudfunctions.net/startOrchestration';

async function runTest() {
  console.log('Starting integration test...');

  try {
    // 1. Trigger the startOrchestration function
    console.log('Triggering startOrchestration function...');
    await axios.post(functionUrl, { userId }).catch(error => {
        console.error('Axios Error:', error.toJSON());
        throw error;
    });

    // 2. Monitor Firestore for completion
    console.log('Monitoring Firestore for orchestration status...');
    const unsubscribe = db.collection('users').doc(userId).collection('orchestraStatus').doc('latest')
      .onSnapshot(async (doc) => {
        const data = doc.data();
        if (data && data.ready) {
          unsubscribe();
          console.log('Orchestration complete. Verifying files...');

          // 3. Verify files in Firebase Storage
          const mp3Exists = await bucket.file(data.mp3StoragePath).exists();
          const midiExists = await bucket.file(data.midiStoragePath).exists();

          if (mp3Exists[0] && midiExists[0]) {
            console.log('SUCCESS: All files created successfully.');
          } else {
            console.error('ERROR: One or more files are missing in Firebase Storage.');
          }

          // 4. Clean up
          console.log('Cleaning up test data...');
          await bucket.file(data.mp3StoragePath).delete();
          await bucket.file(data.midiStoragePath).delete();
          await db.collection('users').doc(userId).collection('orchestraStatus').doc('latest').delete();
          console.log('Cleanup complete.');
          process.exit(0);
        } else if (data && data.error) {
            unsubscribe();
            console.error(`ERROR: Orchestration failed with message: ${data.message}`);
            process.exit(1);
        }
      });

  } catch (error) {
    console.error('Failed to run integration test:', error.message);
    process.exit(1);
  }
}

runTest();
