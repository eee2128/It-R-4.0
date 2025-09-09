
const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const app = express();
const upload = multer({ dest: 'uploads/' });

app.post('/render', upload.single('midiPath'), (req, res) => {
    if (!req.file) {
        return res.status(400).send('No MIDI file uploaded.');
    }

    const midiFilePath = req.file.path;
    const outputFileName = `${path.basename(midiFilePath, '.mid')}.mp3`;
    const outputFilePath = path.join('rendered', outputFileName);
    const soundfontPath = '/usr/share/sounds/sf2/FluidR3_GM.sf2'; // A common path for a default soundfont

    if (!fs.existsSync('rendered')){
        fs.mkdirSync('rendered');
    }

    // Check if the soundfont file exists. If not, you'll need to install one.
    if (!fs.existsSync(soundfontPath)) {
        console.error('Soundfont file not found at:', soundfontPath);
        // In a production environment, you would want to handle this more gracefully
        return res.status(500).send('Server configuration error: Soundfont not found.');
    }

    const command = `fluidsynth -ni "${soundfontPath}" "${midiFilePath}" -o audio.driver=file -o audio.file.name=- -o audio.file.type=wav -r 44100 | lame -b 192 - "${outputFilePath}"`;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            console.error(`stderr: ${stderr}`);
            return res.status(500).send('Failed to convert MIDI to MP3.');
        }

        res.sendFile(path.resolve(outputFilePath), (err) => {
            // Cleanup the uploaded and rendered files
            fs.unlinkSync(midiFilePath);
            fs.unlinkSync(outputFilePath);
            if (err) {
                console.error('Error sending the file:', err);
                // The response may have already been partially sent, so we can't send a new one.
                // We'll just log the error.
            }
        });
    });
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
    console.log(`Render service listening on port ${port}`);
});
