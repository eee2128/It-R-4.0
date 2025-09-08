const functions = require('firebase-functions');
const axios = require('axios');
const admin = require('firebase-admin');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { getFunctions } = require('firebase-admin/functions');

if (!admin.apps.length) {
  admin.initializeApp();
}

const MAGENTA_URL = 'https://magenta-service-66417736961.us-central1.run.app';
const RENDER_URL = 'https://render-service-xxxxxx-uc.a.run.app';

exports.startOrchestration = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }
  const { userId = 'testuser', ...rest } = req.body;
  const statusRef = admin.firestore().collection('users').doc(userId).collection('orchestraStatus').doc('latest');
  await statusRef.set({
    ready: false,
    started: admin.firestore.FieldValue.serverTimestamp(),
    step: 'init',
    message: 'Orchestration request received. Queuing task...'
  });
  const queue = getFunctions().taskQueue('orchestraTaskProcessor');
  await queue.enqueue({ userId, ...rest });
  res.status(202).send({ message: "Orchestration process started" });
});

exports.orchestraTaskProcessor = functions.tasks.taskQueue().onDispatch(async (data) => {
    const {
        notes = [60, 62, 64, 65, 67, 69, 71, 72],
        tempo = 120,
        structure = 'AABA',
        maxDurationSeconds = 120,
        userId,
        midiFileName = `MIDIFile_${Date.now()}`,
        userFileName = null
    } = data;

    const statusRef = admin.firestore().collection('users').doc(userId).collection('orchestraStatus').doc('latest');

    async function deletePreviousFile(ext) {
        const tempFolder = `users/${userId}/temp/`;
        const [files] = await admin.storage().bucket().getFiles({ prefix: tempFolder });
        for (const file of files) {
            if (file.name.endsWith(ext)) {
                await file.delete().catch(() => {});
            }
        }
    }

    try {
        await statusRef.update({ step: 'generating_midi', message: 'Generating MIDI with Magenta' });
        const magentaResponse = await axios.post(`${MAGENTA_URL}/generate`, { notes, tempo, structure, maxDurationSeconds }, { responseType: 'arraybuffer' });
        
        const tempDir = os.tmpdir();
        const midiFileBase = midiFileName.replace(/\.[^/.]+$/, "");
        const midiFileFinal = `${midiFileBase}.midi`;
        const midiFilePath = path.join(tempDir, midiFileFinal);
        fs.writeFileSync(midiFilePath, Buffer.from(magentaResponse.data));

        await deletePreviousFile('.midi');

        await statusRef.update({ step: 'rendering_mp3', message: 'Rendering MP3 from MIDI' });
        const renderResponse = await axios.post(`${RENDER_URL}/render`, { midiPath: midiFilePath, outputFormat: 'mp3' }, { responseType: 'arraybuffer' });

        const mp3FileFinal = `${midiFileBase}.mp3`;
        const mp3FilePath = path.join(tempDir, mp3FileFinal);
        fs.writeFileSync(mp3FilePath, Buffer.from(renderResponse.data));

        await deletePreviousFile('.mp3');

        await statusRef.update({ step: 'uploading_midi', message: 'Uploading MIDI to storage' });
        const midiStoragePath = `users/${userId}/temp/${midiFileFinal}`;
        await admin.storage().bucket().upload(midiFilePath, { destination: midiStoragePath, contentType: 'audio/midi' });

        await statusRef.update({ step: 'uploading_mp3', message: 'Uploading MP3 to storage' });
        const mp3StoragePath = `users/${userId}/temp/${mp3FileFinal}`;
        await admin.storage().bucket().upload(mp3FilePath, { destination: mp3StoragePath, contentType: 'audio/mp3' });

        const expiration = Date.now() + 48 * 60 * 60 * 1000;
        const metadata = { created: Date.now(), userFileName: userFileName || midiFileBase, expiration, midiStoragePath, mp3StoragePath };
        const metadataPath = `users/${userId}/temp/metadata.json`;
        const metadataTempPath = path.join(tempDir, `metadata_${Date.now()}.json`);
        fs.writeFileSync(metadataTempPath, JSON.stringify(metadata));
        await admin.storage().bucket().upload(metadataTempPath, { destination: metadataPath, contentType: 'application/json' });

        if (userFileName) {
            await admin.firestore().collection('users').doc(userId).collection('fileRenames').doc(midiFileBase).set({ userFileName, updated: admin.firestore.FieldValue.serverTimestamp() });
        }

        await statusRef.update({ step: 'generating_urls', message: 'Generating download URLs' });
        const [mp3Url] = await admin.storage().bucket().file(mp3StoragePath).getSignedUrl({ action: 'read', expires: Date.now() + 60 * 60 * 1000 });
        const [midiUrl] = await admin.storage().bucket().file(midiStoragePath).getSignedUrl({ action: 'read', expires: Date.now() + 60 * 60 * 1000 });

        await statusRef.set({ ready: true, mp3Url, midiUrl, mp3StoragePath, midiStoragePath, format: 'mp3', finished: admin.firestore.FieldValue.serverTimestamp(), step: 'done', message: 'Orchestration complete' }, { merge: true });

        fs.unlinkSync(midiFilePath);
        fs.unlinkSync(mp3FilePath);
        fs.unlinkSync(metadataTempPath);

    } catch (error) {
        console.error('Error in orchestraTaskProcessor:', error.message);
        await statusRef.update({ ready: false, step: 'error', message: error.message || 'Unknown error', error: true });
    }
});

exports.deleteExpiredFiles = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    const usersRef = admin.firestore().collection('users');
    const usersSnapshot = await usersRef.get();

    for (const userDoc of usersSnapshot.docs) {
        const tempFolder = `users/${userDoc.id}/temp/`;
        const [files] = await admin.storage().bucket().getFiles({ prefix: tempFolder });

        for (const file of files) {
            if (file.name.endsWith('metadata.json')) {
                const [metadataBuffer] = await file.download();
                const metadata = JSON.parse(metadataBuffer.toString());

                if (metadata.expiration && Date.now() >= metadata.expiration) {
                    await admin.storage().bucket().file(metadata.midiStoragePath).delete().catch(() => {});
                    await admin.storage().bucket().file(metadata.mp3StoragePath).delete().catch(() => {});
                    await file.delete().catch(() => {});
                }
            }
        }
    }
});
