//
//  ExportView.swift
//  MIDI Studio
//
//  Export screen for downloading MIDI files
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var midiFormData: MIDIFormData
    @State private var showingShareSheet = false
    @State private var downloadedMIDIUrl: URL? = nil
    @State private var showMIDIExportSuccess = false

    private var midiFileName: String? {
        guard let urlString = midiFormData.midiUrl, let url = URL(string: urlString) else {
            return nil
        }
        // Extract the last path component and remove query parameters for a clean name
        return URL(string: url.deletingPathExtension().lastPathComponent)?.lastPathComponent
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with custom export icon
                VStack {
                    Spacer()
                        .frame(height: 50)
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(0))
                        
                        Text("Export")
                            .font(.custom("Coustard-Regular", size: 24))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 20)
                }
                .frame(height: 125)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MIDI File Created...")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 300, height: 1)
                        
                        Text("Tap the icon below to save...")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .padding(.top, 12)
                    }
                    
                    // Download Section
                    HStack(spacing: 12) {
                        Button(action: {
                            if let urlString = midiFormData.midiUrl, let url = URL(string: urlString) {
                                downloadAndShareMIDI(url: url)
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(midiFormData.isOrchestraReady ? .black : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!midiFormData.isOrchestraReady)
                        
                        if midiFormData.isOrchestraReady, let fileName = midiFileName {
                            Text(fileName + ".midi")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                
                Spacer()
                
                // Bottom Navigation
                BottomTabView()
            }
        }
        .alert(isPresented: $showMIDIExportSuccess) {
            Alert(title: Text("MIDI file exported successfully!"), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileUrl = downloadedMIDIUrl {
                ShareSheet(items: [fileUrl])
            }
        }
    }
    
    // MARK: - Download Methods
    private func downloadAndShareMIDI(url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { localUrl, _, _ in
            if let localUrl = localUrl {
                // Create a destination URL with the correct file name
                let tempDir = FileManager.default.temporaryDirectory
                let destinationUrl = tempDir.appendingPathComponent(url.lastPathComponent)

                // Remove item if it already exists
                try? FileManager.default.removeItem(at: destinationUrl)

                do {
                    // Move the downloaded file to the destination
                    try FileManager.default.moveItem(at: localUrl, to: destinationUrl)
                    DispatchQueue.main.async {
                        self.downloadedMIDIUrl = destinationUrl
                        self.showingShareSheet = true
                        self.showMIDIExportSuccess = true
                    }
                } catch {
                    print("Error moving file: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}

// MARK: - Share Sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
            .environmentObject(AppState())
            .environmentObject(MIDIFormData())
    }
}
