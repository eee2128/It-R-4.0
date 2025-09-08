//
//  LoadingView.swift
//  MIDI Studio
//
//  Loading screen with progress bar and spinner
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var appState: AppState
    @State private var progress: Double = 0.14
    @State private var rotationAngle: Double = 0
    
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
                    
                    // Progress Bar
                    VStack(spacing: 16) {
                        // Progress Bar
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "D9D9D9"))
                                .frame(width: 300, height: 10)
                            
                            // Progress Fill
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "79BEFF"))
                                .frame(width: 300 * progress, height: 10)
                                .animation(.easeOut(duration: 0.3), value: progress)
                        }
                        
                        // Sending parameters text
                        Text("Sending parameters...")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.black)
                            .frame(maxWidth: 300, alignment: .leading) // Align to the leading edge of the 300 width

                        // Percentage
                        HStack {
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.black)
                        }
                        .frame(width: 300)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                Spacer()
                
                // Bottom Navigation
                BottomTabView()
            }
        }
        .onAppear {
            startAnimations()
            simulateProgress()
        }
    }
    
    private func startAnimations() {
        // Start spinner rotation
        rotationAngle = 360
    }
    
    private func simulateProgress() {
        // Simulate progress from 14% to 100%
        let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            withAnimation(.easeOut(duration: 0.3)) {
                progress += Double.random(in: 0.05...0.20)
                
                if progress >= 1.0 {
                    progress = 1.0
                    timer.invalidate()
                    
                    // Navigate to preview after completion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        appState.currentTab = .preview
                        appState.navigateTo(.preview)
                    }
                }
            }
        }
        
        // Ensure timer runs
        RunLoop.current.add(timer, forMode: .common)
    }
}

// MARK: - Preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .environmentObject(AppState())
    }
}
