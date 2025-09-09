//
//  GenerateView.swift
//  MIDI Studio
//
//  Main MIDI generation form with all parameters
//

import SwiftUI

struct GenerateView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var midiFormData: MIDIFormData
    @FocusState private var tempoFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView(title: "Generate", icon: "music.note")
                
                // Content
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        // Title Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Start Generating")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(height: 1)
                                .frame(maxWidth: 300)
                            
                            Text("Select Parameters to Create MIDI file…")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 40)
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 24) {
                            // Key Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Picker(selection: $midiFormData.key) {
                                    ForEach(MIDIOptions.keys, id: \.self) { key in
                                        Text(key)
                                    }
                                } label: {
                                    HStack {
                                        Text(midiFormData.key.isEmpty ? "Select a key" : midiFormData.key)
                                            .foregroundColor(midiFormData.key.isEmpty ? Color.gray.opacity(0.5) : .black)
                                        Spacer()
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                            // Scale Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Scale")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Picker(selection: $midiFormData.scale) {
                                    ForEach(MIDIOptions.scales, id: \.self) { scale in
                                        Text(scale)
                                    }
                                } label: {
                                    HStack {
                                        Text(midiFormData.scale.isEmpty ? "Select a scale" : midiFormData.scale)
                                            .foregroundColor(midiFormData.scale.isEmpty ? Color.gray.opacity(0.5) : .black)
                                        Spacer()
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                            // Beat Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Beat (beats per measure)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Picker(selection: $midiFormData.beat) {
                                    ForEach(MIDIOptions.beats, id: \.self) { beat in
                                        Text(beat)
                                    }
                                } label: {
                                    HStack {
                                        Text(midiFormData.beat.isEmpty ? "Select a beat" : midiFormData.beat)
                                            .foregroundColor(midiFormData.beat.isEmpty ? Color.gray.opacity(0.5) : .black)
                                        Spacer()
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                            // Tempo Section (Special handling)
                            TempoSection(tempoFieldFocused: $tempoFieldFocused)
                            // Mood Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mood")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Picker(selection: $midiFormData.mood) {
                                    ForEach(MIDIOptions.moods, id: \.self) { mood in
                                        Text(mood)
                                    }
                                } label: {
                                    HStack {
                                        Text(midiFormData.mood.isEmpty ? "Select a mood" : midiFormData.mood)
                                            .foregroundColor(midiFormData.mood.isEmpty ? Color.gray.opacity(0.5) : .black)
                                        Spacer()
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                            // Genre Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Genre")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Picker(selection: $midiFormData.genre) {
                                    ForEach(MIDIOptions.genres, id: \.self) { genre in
                                        Text(genre)
                                    }
                                } label: {
                                    HStack {
                                        Text(midiFormData.genre.isEmpty ? "Select a genre" : midiFormData.genre)
                                            .foregroundColor(midiFormData.genre.isEmpty ? Color.gray.opacity(0.5) : .black)
                                        Spacer()
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                            // Phrase Type Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Desired Musical Phrase Type")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Picker(selection: $midiFormData.phraseType) {
                                    ForEach(MIDIOptions.phraseTypes, id: \.self) { phraseType in
                                        Text(phraseType)
                                    }
                                } label: {
                                    HStack {
                                        Text(midiFormData.phraseType.isEmpty ? "Select musical phrase" : midiFormData.phraseType)
                                            .foregroundColor(midiFormData.phraseType.isEmpty ? Color.gray.opacity(0.5) : .black)
                                        Spacer()
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                            // Voice Type Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Desired Voice Type")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Picker(selection: $midiFormData.voiceType) {
                                    ForEach(MIDIOptions.voiceTypes, id: \.self) { voiceType in
                                        Text(voiceType)
                                    }
                                } label: {
                                    HStack {
                                        Text(midiFormData.voiceType.isEmpty ? "Select voice type" : midiFormData.voiceType)
                                            .foregroundColor(midiFormData.voiceType.isEmpty ? Color.gray.opacity(0.5) : .black)
                                        Spacer()
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                            // Octave Range Multi-Select Dropdown
                            MultiSelectDropdown(
                                title: "Octave Range",
                                description: "Select octave range",
                                options: MIDIOptions.octaveRanges,
                                selection: $midiFormData.octaveRange
                            )
                            // MIDI Length Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("MIDI Length")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Picker(selection: $midiFormData.midiLength) {
                                    ForEach(MIDIOptions.midiLengths, id: \.self) { midiLength in
                                        Text(midiLength)
                                    }
                                } label: {
                                    Text(midiFormData.midiLength.isEmpty ? "Select MIDI length" : midiFormData.midiLength).foregroundColor(.gray)
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        // Generate Button
                        VStack {
                            Button(action: {
                                triggerOrchestraGeneration()
                                appState.navigateTo(.loading)
                            }) {
                                Text("Generate")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                                    .frame(width: 150, height: 40)
                                    .background(Color(hex: "00FF9D"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .cornerRadius(3)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
                
                // Bottom Navigation
                BottomTabView()
            }
        }
        .onTapGesture {
            tempoFieldFocused = false
        }
    }
    
    func triggerOrchestraGeneration() {
        print("--- Attempting network request to Firebase function ---")
        let url = URL(string: "https://us-central1-midi-studio.cloudfunctions.net/startOrchestration")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "key": midiFormData.key,
            "scale": midiFormData.scale,
            "userId": appState.userId ?? "anonymous"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Failed to serialize JSON body: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Use DispatchQueue.main.async to print to the console from the background thread
            DispatchQueue.main.async {
                if let error = error {
                    print("URLSession task failed with error: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Response Status Code: \(httpResponse.statusCode)")
                    if (200...299).contains(httpResponse.statusCode) {
                        print("Firebase function request was successful.")
                    } else {
                        print("Received non-success status code from Firebase function.")
                    }
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Firebase Function Response Body: \(responseBody)")
                    }
                }
            }
        }
        task.resume()
    }
}

// MARK: - Selection Field Component
struct SelectionField: View {
    let title: String
    let description: String
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            Text(description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                    }) {
                        Text(option)
                            .font(.system(size: 16, weight: selection == option ? .semibold : .regular))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - MultiSelectDropdown Component
struct MultiSelectDropdown: View {
    let title: String
    let description: String
    let options: [String]
    @Binding var selection: [String]
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            Text(description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
                .padding(.bottom, 4)
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(selection.isEmpty ? description : selection.joined(separator: ", "))
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    // Select All Option
                    let nonNAOptions = options.filter { $0 != "N/A" }
                    let allSelected = nonNAOptions.allSatisfy { selection.contains($0) }
                    let naSelected = selection.contains("N/A")
                    Button(action: {
                        if naSelected { return }
                        if allSelected {
                            // Deselect all
                            selection.removeAll(where: { nonNAOptions.contains($0) })
                        } else {
                            // Select all except N/A
                            selection = nonNAOptions
                        }
                    }) {
                        HStack {
                            Text("Select All")
                                .foregroundColor(naSelected ? .gray : .black)
                            Spacer()
                            if allSelected && !naSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(naSelected)
                    // Existing options
                    ForEach(options, id: \.self) { option in
                        let isNA = option == "N/A"
                        let naSelected = selection.contains("N/A")
                        let otherSelected = !selection.filter { $0 != "N/A" }.isEmpty
                        let isDisabled = (isNA && otherSelected) || (!isNA && naSelected)
                        Button(action: {
                            if isDisabled { return }
                            if selection.contains(option) {
                                selection.removeAll { $0 == option }
                            } else {
                                if isNA {
                                    selection = ["N/A"]
                                } else {
                                    selection.removeAll { $0 == "N/A" }
                                    selection.append(option)
                                }
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(isDisabled ? .gray : .black)
                                Spacer()
                                if selection.contains(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isDisabled)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Tempo Section Component
struct TempoSection: View {
    @EnvironmentObject var midiFormData: MIDIFormData
    @FocusState.Binding var tempoFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tempo")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            Text("Select a tempo (20 - 240 BPM)")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
                .padding(.bottom, 4)
            
            // Checkbox
            HStack {
                Button(action: {
                    midiFormData.tempoEnabled.toggle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: midiFormData.tempoEnabled ? "checkmark.square" : "square")
                            .foregroundColor(.black)
                        Text("N/A")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            // Tempo Input
            HStack(spacing: 8) {
                TextField("100", value: $midiFormData.tempo, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .keyboardType(.numberPad)
                    .disabled(midiFormData.tempoEnabled)
                    .focused($tempoFieldFocused)
                
                Text("BPM")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Header Component
struct HeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 50)
            
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                
                Text(title)
                    .font(.custom("Coustard-Regular", size: 24))
                    .foregroundColor(.black)
            }
            .padding(.bottom, 20)
        }
        .frame(height: 125)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        let valid = Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            // Fallback to opaque black if invalid
            (a, r, g, b) = (255, 0, 0, 0)
        }
        // Ensure all values are in 0...255
        func clamp(_ v: UInt64) -> Double {
            return Double(min(max(v, 0), 255)) / 255.0
        }
        self.init(
            .sRGB,
            red: valid ? clamp(r) : 0.0,
            green: valid ? clamp(g) : 0.0,
            blue: valid ? clamp(b) : 0.0,
            opacity: valid ? clamp(a) : 1.0
        )
    }
}

// MARK: - Preview
struct GenerateView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateView()
            .environmentObject(AppState())
            .environmentObject(MIDIFormData())
    }
}
