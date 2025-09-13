import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: LiveAuthManager
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var emailSent = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Hintergrund
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Abbrechen") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("Passwort vergessen")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Platzhalter für symmetrisches Layout
                        Text("Abbrechen")
                            .font(.subheadline)
                            .foregroundColor(.clear)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    if emailSent {
                        // Erfolgsmeldung
                        VStack(spacing: 24) {
                            // App Logo
                            VStack(spacing: 8) {
                                Text("11Kölsch")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Bier trinken mit Freunden")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            // Erfolgs-Icon
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            
                            VStack(spacing: 12) {
                                Text("E-Mail gesendet!")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Wir haben Ihnen eine E-Mail mit einem Link zum Zurücksetzen Ihres Passworts gesendet.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Zurück zur Anmeldung Button
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Zurück zur Anmeldung")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 30)
                        }
                    } else {
                        // Formular
                        VStack(spacing: 24) {
                            // App Logo
                            VStack(spacing: 8) {
                                Text("11Kölsch")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Passwort zurücksetzen")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            VStack(spacing: 16) {
                                Text("Geben Sie Ihre E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurücksetzen Ihres Passworts.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                // E-Mail Eingabe
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("E-Mail")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    TextField("ihre@email.de", text: $email)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding(.horizontal, 30)
                                
                                // Link senden Button
                                Button(action: sendResetEmail) {
                                    if isLoading {
                                        HStack {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                            Text("Wird gesendet...")
                                        }
                                    } else {
                                        Text("Link senden")
                                    }
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(email.isEmpty ? Color.gray : Color.red)
                                .cornerRadius(12)
                                .disabled(email.isEmpty || isLoading)
                                .padding(.horizontal, 30)
                                
                                // Zurück zur Anmeldung Link
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("Zurück zur Anmeldung")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                        .underline()
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK") {
                showingError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func sendResetEmail() {
        guard !email.isEmpty else {
            errorMessage = "E-Mail ist erforderlich"
            showingError = true
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Ungültige E-Mail-Adresse"
            showingError = true
            return
        }
        
        // Verwende echte Supabase Auth
        authManager.resetPassword(email: email) { success, error in
            if success {
                emailSent = true
            } else {
                errorMessage = error ?? "Fehler beim Senden der E-Mail. Bitte versuchen Sie es erneut."
                showingError = true
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(LiveAuthManager())
}
