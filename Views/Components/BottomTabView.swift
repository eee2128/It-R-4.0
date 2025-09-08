//
//  BottomTabView.swift
//  MIDI Studio
//
//  Bottom navigation component
//

import SwiftUI

struct BottomTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            HStack(spacing: 0) {
                TabItem(
                    icon: "music.note",
                    title: "Studio",
                    tab: .studio,
                    isActive: appState.currentTab == .studio
                )
                
                TabItem(
                    icon: "waveform",
                    title: "Preview",
                    tab: .preview,
                    isActive: appState.currentTab == .preview
                )
                
                TabItem(
                    icon: "message",
                    title: "Feedback",
                    tab: .feedback,
                    isActive: appState.currentTab == .feedback
                )
            }
            .frame(height: 49)
            .background(Color.white)
        }
    }
}

// MARK: - Tab Item Component
struct TabItem: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var midiFormData: MIDIFormData

    let icon: String
    let title: String
    let tab: AppState.AppTab
    let isActive: Bool
    
    private var isDisabled: Bool {
        // All main tabs are always enabled
        return false
    }

    var body: some View {
        Button(action: {
            appState.navigateToTab(tab)
        }) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(isDisabled ? .gray : .black)
                    .opacity(isActive && !isDisabled ? 1.0 : 0.5)
                
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(isDisabled ? .gray : .black)
                    .opacity(isActive && !isDisabled ? 1.0 : 0.5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 49)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

// MARK: - Preview
struct BottomTabView_Previews: PreviewProvider {
    static var previews: some View {
        BottomTabView()
            .environmentObject(AppState())
            .environmentObject(MIDIFormData())
    }
}
