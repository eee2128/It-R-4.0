
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
    const outputFileName = `${path.basename(midiFilePath, '.midi')}.mp3`;
    const outputFilePath = path.join('rendered', outputFileName);

    if (!fs.existsSync('rendered')){
        fs.mkdirSync('rendered');
    }

    // This is a placeholder for actual MIDI to MP3 conversion.
    // You will need to replace this with a real conversion library or command-line tool.
    // For now, we'll just create a dummy MP3 file.
    fs.writeFileSync(outputFilePath, 'dummy mp3 data');
    res.sendFile(path.resolve(outputFilePath), (err) => {
        // Cleanup the uploaded and rendered files
        fs.unlinkSync(midiFilePath);
        fs.unlinkSync(outputFilePath);
        if (err) {
            res.status(500).send('Error sending the file.');
        }
    });
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
    console.log(`Render service listening on port ${port}`);
});
