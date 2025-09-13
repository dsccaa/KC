//
//  RegistrationView.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authManager: LiveAuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptTerms = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingSuccess = false
    @State private var showingEmailConfirmation = false
    @State private var confirmationMessage = ""
    
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
                    
                    Text("Registrierung")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // Registrierungsformular
                VStack(spacing: 20) {
                    // Name Fields
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vorname")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Max", text: $firstName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nachname")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Mustermann", text: $lastName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    
                    // E-Mail
                    VStack(alignment: .leading, spacing: 8) {
                        Text("E-Mail")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("max@example.de", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Passwort
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Passwort")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SecureField("Mindestens 6 Zeichen", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Passwort bestätigen
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Passwort bestätigen")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SecureField("Passwort wiederholen", text: $confirmPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Terms Checkbox
                    HStack(alignment: .top, spacing: 12) {
                        Button(action: { acceptTerms.toggle() }) {
                            Image(systemName: acceptTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(acceptTerms ? .red : .gray)
                                .font(.title2)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ich akzeptiere die Nutzungsbedingungen und die Datenschutzerklärung")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    
                    // Registrierung Button
                    Button(action: register) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Konto erstellen")
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
                
                // Footer
                VStack(spacing: 8) {
                    Text("Mit der Registrierung akzeptierst du unsere")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 4) {
                        Button("Nutzungsbedingungen") {
                            // Öffne Nutzungsbedingungen
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        
                        Text("und")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Button("Datenschutz") {
                            // Öffne Datenschutz
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 30)
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
            Text("Dein Konto wurde erfolgreich erstellt!")
        }
        .alert("E-Mail-Bestätigung", isPresented: $showingEmailConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(confirmationMessage)
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        acceptTerms
    }
    
    private func register() {
        authManager.registerWithEmail(
            email: email,
            password: password,
            firstName: firstName
        ) { success, error in
            if success {
                showingSuccess = true
            } else {
                errorMessage = error ?? "Fehler bei der Registrierung"
                showingError = true
            }
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(LiveAuthManager())
}