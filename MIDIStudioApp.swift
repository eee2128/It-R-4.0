//
//  MIDIStudioApp.swift
//  MIDI Studio
//
//  Main iOS App Structure
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        #if DEBUG
        // Point Firestore and Auth to local emulators
        let firestore = Firestore.firestore()
        let settings = firestore.settings
        settings.host = "localhost:8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        firestore.settings = settings
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        #endif
        return true
    }
}

@main
struct MIDIStudioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @StateObject private var midiFormData = MIDIFormData()
    @StateObject private var feedbackFormData = FeedbackFormData()

    init() {
        // Initialization code
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(midiFormData)
                .environmentObject(feedbackFormData)
                .preferredColorScheme(.light) // Force light mode to match design
                .onAppear {
                    #if DEBUG
                    print("[DEBUG] Using Firebase Auth emulator at localhost:9099")
                    #else
                    print("[PRODUCTION] Using live Firebase Auth service")
                    #endif
                    if let user = Auth.auth().currentUser {
                        appState.userId = user.uid
                    } else {
                        Auth.auth().signInAnonymously { result, error in
                            if let user = result?.user {
                                appState.userId = user.uid
                                print("Signed in anonymously with UID: \(user.uid)")
                            } else if let error = error as NSError? {
                                print("Firebase anonymous sign-in error: [Code: \(error.code)] \(error.localizedDescription)")
                                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                                    print("Underlying error: [Code: \(underlyingError.code)] \(underlyingError.localizedDescription)")
                                }
                                print("Full error info: \(error.userInfo)")
                            } else {
                                print("Firebase anonymous sign-in failed with unknown error.")
                            }
                        }
                    }
                }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                switch appState.currentView {
                case .launch:
                    LaunchView()
                case .welcome:
                    WelcomeView()
                case .generate:
                    GenerateView()
                case .loading:
                    LoadingView()
                case .preview:
                    PreviewView()
                case .export:
                    ExportView()
                case .feedback:
                    FeedbackView()
                case .feedbackSubmitted:
                    FeedbackSubmittedView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Navigation Router
extension AppState {
    func navigateTo(_ view: AppView) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentView = view
        }
    }
    
    func navigateToTab(_ tab: AppTab) {
        currentTab = tab
        switch tab {
        case .studio:
            navigateTo(.generate)
        case .preview:
            navigateTo(.preview)
        case .feedback:
            navigateTo(.feedback)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(MIDIFormData())
            .environmentObject(FeedbackFormData())
    }
}
