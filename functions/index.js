
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const FormData = require("form-data");

admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

const runtimeOpts = {
  timeoutSeconds: 540,
};

// This is the main orchestration function
exports.startOrchestration = functions.runWith(runtimeOpts).https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  const { userId, key, scale, tempo, mood, genre, phraseType, voiceType, octaveRange, midiLength, beat } = req.body;
  const apiKey = "AIzaSyAiP05GIYS1Pg0Ljs3zFGqCMzphV5Z-qck"; // Your Gemini API Key

  if (!userId) {
    console.error("Orchestration failed: Missing userId");
    return res.status(400).send({ message: "User ID is a required parameter." });
  }

  console.log(`Starting orchestration for user: ${userId}`);
  const docRef = db.collection("users").doc(userId).collection("orchestraStatus").doc("latest");

  try {
    // 1. Initial status
    console.log("Step 1: Setting initial status.");
    await docRef.set({ status: "Composing musical information...", createdAt: admin.firestore.FieldValue.serverTimestamp() });

    // 2. Call the Gemini Developer API to get musical parameters
    console.log("Step 2: Calling Gemini API.");
    const aiServiceUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${apiKey}`;
    const prompt = `Given the following musical parameters: Key: ${key}, Scale: ${scale}, Tempo: ${tempo} BPM, Mood: ${mood}, Genre: ${genre}, Phrase Type: ${phraseType}, Voice Type: ${voiceType}, Octave Range: ${octaveRange}, MIDI Length: ${midiLength} seconds, Beat: ${beat}, generate a corresponding musical composition.`;

    const aiResponse = await axios.post(aiServiceUrl, {
      "contents": [{"parts":[{"text": prompt}]}],
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    console.log("Step 2a: Received response from Gemini API.");
    const musicalData = aiResponse.data.candidates[0].content.parts[0].text; 

    // 3. Generate MIDI with MusicVAE (Magenta)
    console.log("Step 3: Calling MusicVAE service.");
    await docRef.update({ status: "Receiving musical information..." });
    const musicVaeUrl = "https://magenta-service-66417736961.us-central1.run.app/generate";
    
    // Step 3a: Get the URL for the generated MIDI file
    const musicVaeResponse = await axios.post(musicVaeUrl, { "text_input": musicalData }, {
        headers: { 'Content-Type': 'application/json' }
    });

    console.log("Step 3a: Received JSON response from MusicVAE:", JSON.stringify(musicVaeResponse.data));
    const generatedMidiUrl = musicVaeResponse.data.midi_url;

    if (!generatedMidiUrl) {
        throw new Error("MusicVAE service did not return a MIDI URL.");
    }

    // Step 3b: Download the MIDI file from the provided URL
    console.log(`Step 3b: Downloading MIDI file from ${generatedMidiUrl}`);
    const midiDownloadResponse = await axios.get(generatedMidiUrl, {
        responseType: 'arraybuffer'
    });
    const midiData = midiDownloadResponse.data;
    console.log("Step 3c: Received MIDI data from MusicVAE URL.");
    await docRef.update({ status: "Generating MIDI file..." });

    // 4. Save MIDI to Firebase Storage
    console.log("Step 4: Saving MIDI file to Storage.");
    const midiFileName = `generation-${Date.now()}.mid`;
    const midiFile = storage.bucket().file(`users/${userId}/midi/${midiFileName}`);
    await midiFile.save(midiData, { contentType: "audio/midi" });
    console.log("Step 4a: Saved MIDI file.");
    await docRef.update({ status: "Saving MIDI file..." });

    // 5. Render MIDI to MP3 using the render-service
    console.log("Step 5: Calling render service for MP3.");
    await docRef.update({ status: "Rendering audio..." });
    const renderServiceUrl = "https://render-service-66417736961.us-central1.run.app/render"; 
    const form = new FormData();
    form.append('midi_file', midiData, {
        filename: midiFileName,
        contentType: 'audio/midi',
    });
    const renderResponse = await axios.post(renderServiceUrl, form, {
      headers: { ...form.getHeaders() },
      responseType: 'arraybuffer'
    });
    const mp3Data = renderResponse.data;
    console.log("Step 5a: Received MP3 data from render service.");

    // 6. Save MP3 to Firebase Storage
    console.log("Step 6: Saving MP3 file to Storage.");
    const mp3FileName = `generation-${Date.now()}.mp3`;
    const mp3File = storage.bucket().file(`users/${userId}/mp3/${mp3FileName}`);
    await mp3File.save(mp3Data, { contentType: "audio/mpeg" });
    const [mp3Url] = await mp3File.getSignedUrl({ action: 'read', expires: '03-09-2491' });
    console.log("Step 6a: Saved MP3 file.");
    await docRef.update({ status: "Saving audio..." });

    // 7. Finalize Firestore document with MP3 URL
    console.log("Step 7: Finalizing Firestore document.");
    await docRef.update({
      status: "Loading preview...",
      mp3Url: mp3Url,
      midiUrl: await midiFile.getSignedUrl({ action: 'read', expires: '03-09-2491' }).then(urls => urls[0]),
      completedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log("Orchestration successful. Sending 202 response.");
    return res.status(202).send({ message: "Orchestration process started" });

  } catch (error) {
    console.error("Orchestration failed", error);
    let errorMessage = "An unexpected error occurred.";

    if (error.response) {
        console.error('Error Response Body:', error.response.data);
        const errorData = error.response.data;
        if (errorData && errorData.error && errorData.error.message) {
            errorMessage = `[${error.response.status}] ${errorData.error.message}`;
        } else {
            // Convert ArrayBuffer to string if needed
            let responseBody = error.response.data;
            if (responseBody instanceof ArrayBuffer) {
                responseBody = new TextDecoder("utf-8").decode(responseBody);
            }
            errorMessage = `[${error.response.status}] ${JSON.stringify(responseBody)}`;
        }
    } else {
        errorMessage = error.message;
    }

    if(docRef) {
        await docRef.update({
            status: "Error during generation. Please try again.",
            error: errorMessage,
        });
    }

    return res.status(500).send({ message: "Internal Server Error", detail: errorMessage });
  }
});
