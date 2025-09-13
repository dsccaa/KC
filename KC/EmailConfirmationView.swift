//
//  EmailConfirmationView.swift
//  KC
//
//  Created by Dominik Schmidt on 13.09.25.
//

import SwiftUI

struct EmailConfirmationView: View {
    @EnvironmentObject var authManager: LiveAuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var confirmationToken = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingSuccess = false
    
    var body: some View {
        ZStack {
            // Hintergrund - Dunkles Design
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo/Title
                VStack(spacing: 20) {
                    Text("11Kölsch")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text("E-Mail bestätigen")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // Bestätigungsformular
                VStack(spacing: 20) {
                    Text("Gib den Bestätigungscode ein, den wir dir per E-Mail gesendet haben.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Bestätigungscode
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bestätigungscode")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("6-stelliger Code", text: $confirmationToken)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.numberPad)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Bestätigen Button
                    Button(action: confirmEmail) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("E-Mail bestätigen")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || authManager.isLoading)
                    
                    // Zurück zur Anmeldung Link
                    Button(action: { dismiss() }) {
                        Text("Zurück zur Anmeldung")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .underline()
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Erfolgreich", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Deine E-Mail wurde erfolgreich bestätigt!")
        }
    }
    
    private var isFormValid: Bool {
        !confirmationToken.isEmpty && confirmationToken.count == 6
    }
    
    private func confirmEmail() {
        authManager.confirmEmail(token: confirmationToken) { success, error in
            if success {
                showingSuccess = true
            } else {
                errorMessage = error ?? "Fehler bei der E-Mail-Bestätigung"
                showingError = true
            }
        }
    }
}

#Preview {
    EmailConfirmationView()
        .environmentObject(LiveAuthManager())
}
