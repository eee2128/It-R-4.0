# MIDI Studio iOS App - SwiftUI

A native iOS recreation of the MIDI Studio app built with SwiftUI. This app allows users to generate creative MIDI files with customizable parameters including key, scale, tempo, mood, genre, and more.

## Features

- **Launch Screen**: Beautiful animated gradient logo
- **Welcome Screen**: Feature overview with onboarding
- **MIDI Generation**: Comprehensive form with all musical parameters
- **Loading Screen**: Animated progress tracking
- **Audio Preview**: Playback controls with progress visualization
- **File Export**: Native iOS sharing for MIDI files
- **Feedback System**: User feedback form with validation
- **Bottom Navigation**: Seamless tab-based navigation

## Project Structure

```
MIDIStudioApp.swift                 # Main App file
Models/
    MIDIFormData.swift              # Data models & state management
Views/
    LaunchView.swift                # Splash screen
    WelcomeView.swift               # Onboarding screen
    GenerateView.swift              # Main MIDI form
    LoadingView.swift               # Progress screen
    PreviewView.swift               # Audio player
    ExportView.swift                # File sharing
    FeedbackView.swift              # Feedback form
    FeedbackSubmittedView.swift     # Success screen
    Components/
        BottomTabView.swift         # Navigation component
Supporting Files/
    Info.plist                      # App configuration
README.md                           # This file
```

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd <repo-folder>
   ```
2. **Open the project in Xcode:**
   - Double-click `MIDI Studio.xcodeproj` to open in Xcode.
3. **Install dependencies:**
   - If you use Swift Package Manager, Xcode will resolve packages automatically.
   - If you use CocoaPods or other tools, run the appropriate install command.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Support

If you encounter any issues or have questions, please open an issue in this repository.

## License

This project is licensed under the MIT License.
