//
//  LaunchView.swift
//  MIDI Studio
//
//  Launch/Splash screen with app logo
//

import SwiftUI

struct LaunchView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // App Icon with animated gradient
                ZStack {
                    // Main gradient orb
 Image("logo1")
 .resizable()
 .scaledToFit()
 .frame(width: 250, height: 250)
                        .scaleEffect(animateGradient ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: animateGradient
                        )
                }
                // App Title
                Text("MIDI Studio")
                    .font(.custom("Coustard-Regular", size: 30))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 88)
        }
        .onAppear {
            animateGradient = true
            
            // Auto-navigate to welcome after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                appState.navigateTo(.welcome)
            }
        }
    }
}

// MARK: - Preview
struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
            .environmentObject(AppState())
    }
}
