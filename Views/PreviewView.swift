//
//  PreviewView.swift
//  MIDI Studio
//
//  Audio preview screen with playback controls
//

import SwiftUI
import AVFoundation

struct PreviewView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var midiFormData: MIDIFormData
    
    // Audio Engine State
    @State private var audioEngine = AVAudioEngine()
    @State private var audioPlayerNode = AVAudioPlayerNode()
    @State private var audioFile: AVAudioFile?
    
    // UI State
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var totalTime: Double = 0
    @State private var playbackTimer: Timer?
    @State private var showShareSheet = false
    @State private var fileLoaded = false
    @State private var downloadedFileUrl: URL? = nil
    @State private var showMP3ExportSuccess = false
    
    var progressPercentage: Double {
        totalTime > 0 ? currentTime / totalTime : 0
    }
    
    var body: some View {
        ZStack {
            Color.white
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HeaderView(title: "Preview", icon: "waveform")
                    
                    // Content
                    VStack(alignment: .leading, spacing: 32) {
                        // Title Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tap 'Play' to Begin Preview")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 300, height: 1)
                        }
                        
                        // Files Section
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Tap the export icon to save")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                            
                            // Audio Player
                            VStack(spacing: 12) {
                                // Player Bar
                                ZStack {
                                    Rectangle()
                                        .fill(fileLoaded ? Color.black : Color.gray.opacity(0.5))
                                        .frame(width: 278, height: 40)
                                        .cornerRadius(8)
                                    HStack(spacing: 0) {
                                        Spacer(minLength: 0)
                                        // Play Button
                                        Button(action: togglePlayback) {
                                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(fileLoaded ? .white : Color.white.opacity(0.5))
                                        }
                                        .disabled(!fileLoaded)
                                        .frame(width: 36, height: 40)
                                        Spacer(minLength: 0)
                                        // Progress Bar
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(fileLoaded ? Color.white : Color.white.opacity(0.5))
                                                .frame(height: 5)
                                            if fileLoaded {
                                                Rectangle()
                                                    .fill(Color.black.opacity(0.38))
                                                    .frame(width: 130 * progressPercentage, height: 5)
                                            }
                                        }
                                        .frame(height: 5)
                                        Spacer(minLength: 0)
                                        // Time Display
                                        Text(fileLoaded ? "\(formatTime(currentTime)) / \(formatTime(totalTime))" : "00:00 / 00:00")
                                            .font(.system(size: 12))
                                            .foregroundColor(fileLoaded ? .white : Color.white.opacity(0.5))
                                            .frame(width: 80, height: 40, alignment: .center)
                                        Spacer(minLength: 0)
                                    }
                                    .frame(width: 278, height: 40)
                                }
                                .padding(.horizontal, 20)
                                // File Name
                                if fileLoaded, let url = downloadedFileUrl {
                                    Text(url.lastPathComponent)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        
                        // Control Buttons
                        HStack {
                            Spacer()
                            
                            Button {
                                if downloadedFileUrl != nil {
                                    self.showShareSheet = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 20))
                                        .foregroundColor(fileLoaded ? .black : .gray)
                                    Text("Save audio")
                                        .foregroundColor(fileLoaded ? .black : .gray)
                                }
                            }
                            .disabled(!fileLoaded)
                            .sheet(isPresented: $showShareSheet, onDismiss: {
                                // Show the success alert after the share sheet is dismissed
                                self.showMP3ExportSuccess = true
                            }) {
                                if let fileUrl = downloadedFileUrl {
                                    ShareSheet(items: [fileUrl])
                                }
                            }
                            
                            Button(action: {
                                appState.navigateTo(.export)
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                Text("Export MIDI")
                                    .foregroundColor(.black);
                            }
                            .padding(.leading, 16)
                        }
                        .frame(width: 300)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 40)
                    
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showMP3ExportSuccess) {
            Alert(title: Text(".mp3 file saved/exported successfully!"), dismissButton: .default(Text("OK")))
        }
        .safeAreaInset(edge: .bottom) {
            BottomTabView()
        }
        .onAppear(perform: downloadInitialFile)
        .onDisappear(perform: stopPlayback)
    }
    
    // MARK: - Audio Control Methods
    private func setupAudio(url: URL) {
        do {
            audioFile = try AVAudioFile(forReading: url)
            
            guard let audioFile = audioFile else { return }

            let audioFormat = audioFile.processingFormat
            totalTime = Double(audioFile.length) / audioFormat.sampleRate

            audioEngine.attach(audioPlayerNode)
            audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFormat)
            audioEngine.prepare()
            try audioEngine.start()
            
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: {
                DispatchQueue.main.async {
                    self.isPlaying = false
                }
            })
            
            fileLoaded = true
        } catch {
            print("Error setting up audio: \(error.localizedDescription)")
            fileLoaded = false
        }
    }

    private func togglePlayback() {
        guard fileLoaded else { return }
        
        isPlaying.toggle()
        
        if isPlaying {
            audioPlayerNode.play()
            startPlaybackTimer()
        } else {
            audioPlayerNode.pause()
            stopPlaybackTimer()
        }
    }
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let nodeTime = audioPlayerNode.lastRenderTime, let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else {
                return
            }
            currentTime = Double(playerTime.sampleTime) / playerTime.sampleRate
            
            if currentTime >= totalTime {
                stopPlayback()
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func stopPlayback() {
        isPlaying = false
        audioPlayerNode.stop()
        stopPlaybackTimer()
        // Reset for next playback
        currentTime = 0
        if let audioFile = audioFile {
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        } else {
            // Optionally handle the error, e.g., log or show an alert
            print("Warning: Tried to schedule playback but audioFile is nil.")
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func downloadInitialFile() {
        if let urlString = midiFormData.mp3Url, let url = URL(string: urlString) {
            let task = URLSession.shared.downloadTask(with: url) { localUrl, _, error in
                if let error = error {
                    print("Download error: \(error.localizedDescription)")
                    return
                }
                
                if let localUrl = localUrl {
                    DispatchQueue.main.async {
                        // Move to a permanent location
                        let tempDir = FileManager.default.temporaryDirectory
                        let permanentUrl = tempDir.appendingPathComponent(url.lastPathComponent)
                        try? FileManager.default.removeItem(at: permanentUrl) // Remove if exists
                        try? FileManager.default.moveItem(at: localUrl, to: permanentUrl)
                        
                        self.downloadedFileUrl = permanentUrl
                        self.setupAudio(url: permanentUrl)
                    }
                }
            }
            task.resume()
        }
    }
}

// MARK: - Preview
struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView()
            .environmentObject(AppState())
            .environmentObject(MIDIFormData())
    }
}
