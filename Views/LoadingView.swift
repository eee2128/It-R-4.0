//
//  LoadingView.swift
//  MIDI Studio
//
//  Loading screen with progress bar and spinner
//

import SwiftUI
import FirebaseFirestore

struct LoadingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var midiFormData: MIDIFormData
    
    @State private var statusText: String = "Sending parameters..."
    @State private var rotationAngle: Double = 0
    @State private var listener: ListenerRegistration?

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView(title: "Creating....", icon: "music.note")
                
                Spacer()
                
                // Content
                VStack(spacing: 24) {
                    // Spinner
                    Circle()
                        .trim(from: 0.25, to: 1.0)
                        .stroke(Color.black.opacity(0.5), lineWidth: 3)
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(
                            Animation.linear(duration: 1.0)
                                .repeatForever(autoreverses: false),
                            value: rotationAngle
                        )
                    
                    // Loading Text and Divider
                    VStack(spacing: 8) {
                        Text("Loading...")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 300, height: 1)
                    }
                    
                    // Status Text
                    Text(statusText)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.black)
                        .frame(maxWidth: 300, alignment: .center)
                        .padding(.top, 16)

                }
                .padding(.horizontal, 40)
                
                Spacer()
                Spacer()
                
                // Bottom Navigation
                BottomTabView()
            }
        }
        .onAppear(perform: setupListener)
        .onDisappear(perform: cleanupListener)
    }
    
    private func setupListener() {
        // Start spinner animation
        rotationAngle = 360
        
        guard let userId = appState.userId else {
            statusText = "Error: User not logged in."
            return
        }
        
        statusText = "Orchestration started. Waiting for file..."
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId).collection("orchestraStatus").document("latest")

        listener = docRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                statusText = "Error fetching result. Please try again."
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                // This is normal while the function is running
                statusText = "Generation in progress..."
                return
            }
            
            // Check for the MP3 URL
            if let mp3Url = data["mp3Url"] as? String {
                print("Received MP3 URL: \(mp3Url)")
                midiFormData.mp3Url = mp3Url
                
                // Invalidate the listener
                cleanupListener()
                
                // Navigate to the preview screen
                statusText = "File ready. Loading preview..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { 
                    appState.currentTab = .preview
                    appState.navigateTo(.preview)
                }
            } else if let status = data["status"] as? String {
                // Optional: Update status text based on backend progress
                statusText = status
            }
        }
    }

    private func cleanupListener() {
        listener?.remove()
        listener = nil
        print("Firestore listener removed.")
    }
}

// MARK: - Preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let midiFormData = MIDIFormData()
        // Simulate a logged-in user for preview
        appState.userId = "previewUser"
        
        return LoadingView()
            .environmentObject(appState)
            .environmentObject(midiFormData)
    }
}
