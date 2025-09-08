//
//  FeedbackView.swift
//  MIDI Studio
//
//  Feedback form screen
//

import FirebaseFirestore
import SwiftUI
import Combine

struct FeedbackView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var feedbackFormData: FeedbackFormData
    @FocusState private var focusedField: FeedbackField?
    @State private var showSubmitError = false
    
    enum FeedbackField {
        case name, phone, email, comments
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView(title: "Feedback", icon: "message")
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Feedback Form 🗣️")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 300, height: 1)
                        }
                        .padding(.horizontal, 40)
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 24) {
                            FeedbackFormField(
                                title: "Name",
                                placeholder: "Enter your name",
                                text: $feedbackFormData.name,
                                focusedField: $focusedField,
                                field: .name
                            )
                            
                            FeedbackFormField(
                                title: "Phone number",
                                placeholder: "Enter your phone number",
                                text: $feedbackFormData.phone,
                                focusedField: $focusedField,
                                field: .phone,
 keyboardType: .phonePad,
 isPhoneNumber: true
                            )
                            
                            FeedbackFormField(
                                title: "Email",
                                placeholder: "Enter your email",
                                text: $feedbackFormData.email,
                                focusedField: $focusedField,
                                field: .email,
                                keyboardType: .emailAddress
                            )
                            
                            FeedbackFormField(
                                title: "Comments",
                                placeholder: "Enter questions, comments, suggestions...",
                                text: $feedbackFormData.comments,
                                focusedField: $focusedField,
                                field: .comments,
                                isMultiline: true
                            )
                        }
                        .padding(.horizontal, 40)
                        
                        // Submit Button
                        VStack {
                            Button(action: submitFeedback) {
                                Text("Submit")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                                    .frame(width: 150, height: 40)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color(hex: "CECDCD"), lineWidth: 1)
                                    )
                                    .cornerRadius(3)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                        
                        // App Store Rating
                        VStack(alignment: .leading) {
                            Text("🌟 Rate Us in the App Store...")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .lineHeight(30)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
                
                Spacer()
                
                // Bottom Navigation
                BottomTabView()
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .alert(isPresented: $showSubmitError) {
            Alert(
                title: Text("Form not submitted. Please try again."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func submitFeedback() {
        // Validate and submit feedback
        guard feedbackFormData.isValid else {
            // Show validation error
            return
        }
        
        let feedbackData: [String: Any] = [
            "name": feedbackFormData.name,
            "phone": feedbackFormData.phone,
            "email": feedbackFormData.email,
            "comments": feedbackFormData.comments,
            "timestamp": Timestamp(date: Date())
        ]
        
        Firestore.firestore().collection("feedback").addDocument(data: feedbackData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                showSubmitError = true
            } else {
                appState.navigateTo(.feedbackSubmitted)
            }
        }
    }
}

// MARK: - Feedback Form Field Component
struct FeedbackFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var focusedField: FeedbackView.FeedbackField?
    let field: FeedbackView.FeedbackField
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false
 var isPhoneNumber: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
            
            if isMultiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .textFieldStyle(UnderlineTextFieldStyle())
                    .focused($focusedField, equals: field)
                    .keyboardType(keyboardType)
                    .lineLimit(3...6)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(UnderlineTextFieldStyle())
                    .focused($focusedField, equals: field)
                    .keyboardType(keyboardType)
 .onChange(of: text) { newValue in
 if isPhoneNumber {
 text = formatPhoneNumber(newValue)
 }
 }
 .onReceive(Just(text)) { newValue in
 if isPhoneNumber {
 text = formatPhoneNumber(newValue)
 }
 }
            }
        }
    }
}

// MARK: - Custom Underline Text Field Style
struct UnderlineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(spacing: 8) {
            configuration
                .padding(.vertical, 12)
                .font(.system(size: 14, weight: .regular))
            
            Rectangle()
                .fill(Color(hex: "E6E6E6"))
                .frame(height: 1)
                .frame(maxWidth: 300)
        }
    }
}

// MARK: - Phone Number Formatting
func formatPhoneNumber(_ phoneNumber: String) -> String {
    let cleanPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let limitedPhoneNumber = String(cleanPhoneNumber.prefix(11))
    let mask: String
    switch limitedPhoneNumber.count {
    case 7:
        mask = "XXX-XXXX"
    case 10:
        mask = "(XXX) XXX-XXXX"
    case 11:
        mask = "X(XXX) XXX-XXXX"
    default:
        return limitedPhoneNumber // Return truncated if not 7, 10, or 11 digits
    }
    
    var result = ""
    var index = limitedPhoneNumber.startIndex
    for ch in mask where index < limitedPhoneNumber.endIndex {
        if ch == "X" {
            result.append(limitedPhoneNumber[index])
            index = limitedPhoneNumber.index(after: index)
        } else {
            result.append(ch)
        }
    }
    return result
}

// MARK: - Phone Number Validation (Can be used in submitFeedback if needed)
func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
    let cleanPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
 return cleanPhoneNumber.count == 7 || cleanPhoneNumber.count == 10 || cleanPhoneNumber.count == 11
}

// MARK: - Line Height Modifier
extension Text {
    func lineHeight(_ height: CGFloat) -> some View {
        self.lineSpacing(height - UIFont.systemFont(ofSize: 16).lineHeight)
    }
}

// MARK: - Preview
struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
            .environmentObject(AppState())
            .environmentObject(FeedbackFormData())
    }
}
