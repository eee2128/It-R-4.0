
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const FormData = require("form-data");
const { getAccessToken } = require('./auth'); // Helper for auth

admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

// This is the main orchestration function
exports.startOrchestration = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  const { userId, key, scale, tempo, mood, genre, phraseType, voiceType, octaveRange, midiLength, beat } = req.body;

  if (!userId) {
    return res.status(400).send({ message: "User ID is a required parameter." });
  }

  const docRef = db.collection("users").document(userId).collection("orchestraStatus").document("latest");

  try {
    // 1. Initial status
    await docRef.set({ status: "Composing musical information...", createdAt: admin.firestore.FieldValue.serverTimestamp() });

    // 2. Call the AI service to get musical parameters
    const accessToken = await getAccessToken();
    const aiServiceUrl = `https://us-central1-aiplatform.googleapis.com/v1/projects/midi-studio/locations/us-central1/publishers/google/models/gemini-1.5-flash-001:generateContent`;

    const prompt = `Given the following musical parameters: Key: ${key}, Scale: ${scale}, Tempo: ${tempo} BPM, Mood: ${mood}, Genre: ${genre}, Phrase Type: ${phraseType}, Voice Type: ${voiceType}, Octave Range: ${octaveRange}, MIDI Length: ${midiLength} seconds, Beat: ${beat}, generate a corresponding musical composition.`;

    const aiResponse = await axios.post(aiServiceUrl, {
      "contents": [{"parts":[{"text": prompt}]}],
    }, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    });

    // Note: The response structure might be complex. Adjust this line based on the actual API response.
    const musicalData = aiResponse.data.candidates[0].content.parts[0].text; 

    // 3. Generate MIDI with MusicVAE (Magenta)
    await docRef.update({ status: "Receiving musical information..." });
    const musicVaeUrl = "https://magenta-service-66417736961.us-central1.run.app"; 
    const musicVaeResponse = await axios.post(musicVaeUrl, musicalData, {
        responseType: 'arraybuffer' // Expecting binary MIDI data
    });
    const midiData = musicVaeResponse.data;
    await docRef.update({ status: "Generating MIDI file..." });


    // 4. Save MIDI to Firebase Storage
    const midiFileName = `generation-${Date.now()}.mid`;
    const midiFile = storage.bucket().file(`users/${userId}/midi/${midiFileName}`);
    await midiFile.save(midiData, { contentType: "audio/midi" });
    await docRef.update({ status: "Saving MIDI file..." });

    // 5. Render MIDI to MP3 using the render-service
    await docRef.update({ status: "Rendering audio..." });
    const renderServiceUrl = "https://render-service-66417736961.us-central1.run.app"; 

    const form = new FormData();
    form.append('midi_file', midiData, {
        filename: midiFileName,
        contentType: 'audio/midi',
    });

    const renderResponse = await axios.post(renderServiceUrl, form, {
      headers: {
        ...form.getHeaders(),
      },
      responseType: 'arraybuffer' // Expecting binary MP3 data
    });
    const mp3Data = renderResponse.data;


    // 6. Save MP3 to Firebase Storage
    const mp3FileName = `generation-${Date.now()}.mp3`;
    const mp3File = storage.bucket().file(`users/${userId}/mp3/${mp3FileName}`);
    await mp3File.save(mp3Data, { contentType: "audio/mpeg" });
    const [mp3Url] = await mp3File.getSignedUrl({
        action: 'read',
        expires: '03-09-2491' // A very long expiration date
    });
    await docRef.update({ status: "Saving audio..." });


    // 7. Finalize Firestore document with MP3 URL
    await docRef.update({
      status: "Loading preview...",
      mp3Url: mp3Url,
      midiUrl: await midiFile.getSignedUrl({ action: 'read', expires: '03-09-2491' }).then(urls => urls[0]),
      completedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return res.status(202).send({ message: "Orchestration process started" });

  } catch (error) {
    console.error("Orchestration failed", error);
    let errorMessage = "An unexpected error occurred.";

    if (error.response) {
        console.error('Error Response:', error.response.data);
        const errorData = error.response.data;
        if (errorData && errorData.error && errorData.error.message) {
            errorMessage = `[${error.response.status}] ${errorData.error.message}`;
        } else {
            errorMessage = `[${error.response.status}] ${JSON.stringify(errorData)}`;
        }
    } else {
        errorMessage = error.message;
    }

    await docRef.update({
        status: "Error during generation. Please try again.",
        error: errorMessage,
    });

    return res.status(500).send({ message: "Internal Server Error", detail: errorMessage });
  }
});
