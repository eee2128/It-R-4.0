//
//  FeedbackSubmittedView.swift
//  MIDI Studio
//
//  Feedback submission success screen
//

import SwiftUI

struct ScaledFont: ViewModifier {
    var name: String
    var size: CGFloat
    @Environment(\.sizeCategory) var sizeCategory

    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}

extension View {
    func scaledFont(name: String, size: CGFloat) -> some View {
        self.modifier(ScaledFont(name: name, size: size))
    }
}

struct FeedbackSubmittedView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var feedbackFormData: FeedbackFormData
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with checkmark
                VStack {
                    Spacer()
                        .frame(height: 50)
                    
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        
                        Text("Feedback Submitted")
                            .modifier(ScaledFont(name: "Coustard-Regular", size: 24))
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
                        Text("Thanks for Your Feedback!")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 300, height: 1)
                    }
                    
                    // Success Message
                    VStack {
                        Text("Your Feedback has been Submitted Successfully!")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .frame(width: 300, height: 200)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 200)
                }
                .padding(.horizontal, 40)
                .padding(.top, 24)
                
                Spacer()
                
                // Bottom Navigation
                BottomTabView()
            }
        }
        .onAppear {
            // Clear the form data after successful submission
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                feedbackFormData.reset()
                
                // Auto-navigate back to main screen after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    appState.currentTab = .studio
                    appState.navigateTo(.generate)
                }
            }
        }
    }
}

// MARK: - Preview
struct FeedbackSubmittedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackSubmittedView()
            .environmentObject(AppState())
            .environmentObject(FeedbackFormData())
    }
}
