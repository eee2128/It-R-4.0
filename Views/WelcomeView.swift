//
//  WelcomeView.swift
//  MIDI Studio
//
//  Welcome/Onboarding screen with features overview
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateFeatures = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 149)
                
                // Welcome Title
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome to")
                        .font(.custom("Coustard-Regular", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text("MIDI Studio...")
                        .font(.custom("Coustard-Regular", size: 24))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 36)
                
                Spacer()
                    .frame(height: 70)
                
                // App Icon
                ZStack {
                    Image("logo1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 210)
                }
                
                Spacer()
                    .frame(height: 15)
                
                // Features List
                VStack(alignment: .leading, spacing: 30) {
                    FeatureRow(
                        text: "Generate creative and unique MIDIs...",
                        delay: 0.0
                    )
                    
                    FeatureRow(
                        text: "Improve Your GarageBand Projects…",
                        delay: 0.3
                    )
                    
                    FeatureRow(
                        text: "Discover a new sound...",
                        delay: 0.6
                    )
                }
                .padding(.horizontal, 36)
                .opacity(animateFeatures ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8), value: animateFeatures)
                
                Spacer()
            }
        }
        .onAppear {
            // Animate features in
            withAnimation(.easeInOut(duration: 0.8).delay(0.5)) {
                animateFeatures = true
            }
            
            // Auto-navigate to generate after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                appState.currentTab = .studio
                appState.navigateTo(.generate)
            }
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let text: String
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("∙")
                .font(.custom("Coustard-Regular", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            
            Text(text)
                .font(.custom("Coustard-Regular", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(x: isVisible ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(delay), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AppState())
    }
}
