
//
//  MIDIFormData.swift
//  MIDI Studio
//
//  Data models for MIDI generation parameters
//

import Foundation
import FirebaseFirestore

// MARK: - Main Form Data Model
class MIDIFormData: ObservableObject {
    @Published var key: String = "C"
    @Published var scale: String = "major"
    @Published var beat: String = "4/4"
    @Published var tempo: Int = 120
    @Published var tempoEnabled: Bool = false
    @Published var mood: String = "N/A"
    @Published var genre: String = "N/A"
    @Published var phraseType: String = "N/A"
    @Published var voiceType: String = "N/A"
    @Published var octaveRange: [String] = []
    @Published var midiLength: String = "N/A"
    @Published var isOrchestraReady: Bool = false
    @Published var mp3Url: String? = nil
    @Published var midiUrl: String? = nil

    private var listener: ListenerRegistration?

    // MARK: - Reset Form
    func reset() {
        key = "C"
        scale = "major"
        beat = "4/4"
        tempo = 120
        tempoEnabled = false
        mood = "N/A"
        genre = "N/A"
        phraseType = "N/A"
        voiceType = "N/A"
        octaveRange = []
        midiLength = "N/A"
    }
    
    // MARK: - Validation
    var isValid: Bool {
        return !key.isEmpty && !scale.isEmpty && !beat.isEmpty && !octaveRange.isEmpty
    }
    
    func observeOrchestraStatus(userId: String) {
        listener?.remove()
        let db = Firestore.firestore()
        listener = db.collection("users").document(userId).collection("orchestraStatus").document("latest")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    self?.isOrchestraReady = false
                    self?.mp3Url = nil
                    self?.midiUrl = nil
                    return
                }
                self?.isOrchestraReady = (data["ready"] as? Bool) ?? false
                self?.mp3Url = data["mp3Url"] as? String
                self?.midiUrl = data["midiUrl"] as? String
            }
    }

    deinit {
        listener?.remove()
    }
}

// MARK: - Selection Options
struct MIDIOptions {
    static let keys = ["C", "D", "E", "F", "G", "A", "B", "N/A"]
    
    static let scales = ["major", "minor", "N/A"]
    
    static let beats = ["2/4", "3/4", "4/4", "6/8", "N/A"]
    
    static let moods = [
        "ambient", "bright", "dramatic", "happy", "melancholic",
        "mysterious", "peaceful", "playful", "relaxed", "romantic",
        "sad", "uplifting", "N/A"
    ]
    
    static let genres = [
        "ambient", "blues", "classical", "country", "electronic", "edm",
        "experimental", "folk", "hiphop", "ice pop", "jazz", "latin",
        "metal", "noise", "pop", "rap", "reggae", "r&b", "samba",
        "singer-songwriter", "rock", "trap", "world", "N/A"
    ]
    
    static let phraseTypes = [
        "melody", "riff", "baseline", "chords", "chord-progression",
        "scale-inspired", "N/A"
    ]
    
    static let voiceTypes = [
        "bass", "baritone", "tenor", "alto", "mezzo-soprano", "soprano", "N/A"
    ]
    
    static let octaveRanges = [
        "0 (A0 to B0)", "1 (C1 to B1)", "2 (C2 to B2)", "3 (C3 to B3)",
        "4 (C4 (middle C) to B4)", "5 (C5 to B5)", "6 (C6 to B6)",
        "7 (C7 to B7)", "8 (C8 (highest note))", "N/A"
    ]
    
    static let midiLengths = ["Short", "Medium", "Long", "N/A"]
}

// MARK: - Feedback Form Data
class FeedbackFormData: ObservableObject {
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var comments: String = ""
    
    func reset() {
        name = ""
        phone = ""
        email = ""
        comments = ""
    }
    
    var isValid: Bool {
        return !name.isEmpty && !email.isEmpty
    }
}

// MARK: - App State Management
class AppState: ObservableObject {
    @Published var currentTab: AppTab = .studio
    @Published var currentView: AppView = .launch
    @Published var loadingProgress: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var userId: String? = nil
    
    enum AppTab: CaseIterable {
        case studio, preview, feedback
        
        var title: String {
            switch self {
            case .studio: return "Studio"
            case .preview: return "Preview"
            case .feedback: return "Feedback"
            }
        }
        
        var systemImage: String {
            switch self {
            case .studio: return "music.note"
            case .preview: return "waveform"
            case .feedback: return "message"
            }
        }
    }
    
    enum AppView {
        case launch, welcome, generate, loading, preview, export, feedback, feedbackSubmitted
    }
}
