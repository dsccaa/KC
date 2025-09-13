//
//  LiveAuthManager.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import Foundation
import Supabase

// MARK: - Live Authentication Manager
class LiveAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let liveSupabaseService: LiveSupabaseService
    
    init() {
        print("🚀 LiveAuthManager: Initialisiert mit echter Supabase-Integration")
        self.liveSupabaseService = LiveSupabaseService()
    }
    
    // MARK: - Authentication Methods
    
    /// Login mit E-Mail und Passwort
    func loginWithEmail(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        print("📧 LiveAuthManager: E-Mail Login starten für: \(email)")
        
        // Validiere E-Mail
        guard isValidEmail(email) else {
            print("❌ LiveAuthManager: Ungültige E-Mail")
            completion(false, "Ungültige E-Mail-Adresse")
            return
        }
        
        // Validiere Passwort
        guard !password.isEmpty else {
            print("❌ LiveAuthManager: Passwort ist leer")
            completion(false, "Passwort ist erforderlich")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let user = try await liveSupabaseService.loginWithEmail(email: email, password: password) {
                    await MainActor.run {
                        self.isLoading = false
                        self.currentUser = user
                        self.isAuthenticated = true
                        print("✅ LiveAuthManager: E-Mail Login erfolgreich")
                        completion(true, nil)
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Anmeldung fehlgeschlagen"
                        print("❌ LiveAuthManager: E-Mail Login fehlgeschlagen")
                        completion(false, self.errorMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Login Fehler: \(error.localizedDescription)"
                    print("❌ LiveAuthManager: E-Mail Login Fehler: \(error.localizedDescription)")
                    completion(false, self.errorMessage)
                }
            }
        }
    }
    
    /// Registrierung mit E-Mail und Passwort
    func registerWithEmail(email: String, password: String, firstName: String, completion: @escaping (Bool, String?) -> Void) {
        print("📧 LiveAuthManager: E-Mail Registrierung starten für: \(email)")
        
        // Validiere E-Mail
        guard isValidEmail(email) else {
            print("❌ LiveAuthManager: Ungültige E-Mail")
            completion(false, "Ungültige E-Mail-Adresse")
            return
        }
        
        // Validiere Passwort
        guard password.count >= 6 else {
            print("❌ LiveAuthManager: Passwort zu kurz")
            completion(false, "Passwort muss mindestens 6 Zeichen lang sein")
            return
        }
        
        // Validiere Vorname
        guard !firstName.isEmpty else {
            print("❌ LiveAuthManager: Vorname ist leer")
            completion(false, "Vorname ist erforderlich")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Registriere User mit E-Mail-Bestätigung
                if let user = try await liveSupabaseService.registerWithEmail(
                    email: email, 
                    password: password,
                    metadata: [
                        "first_name": AnyJSON.string(firstName),
                        "email": AnyJSON.string(email)
                    ]
                ) {
                    await MainActor.run {
                        self.isLoading = false
                        self.currentUser = user
                        self.isAuthenticated = true
                        print("✅ LiveAuthManager: E-Mail Registrierung erfolgreich")
                        completion(true, "Registrierung erfolgreich! Du kannst dich jetzt anmelden.")
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Registrierung fehlgeschlagen"
                        print("❌ LiveAuthManager: E-Mail Registrierung fehlgeschlagen")
                        completion(false, self.errorMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Registrierung Fehler: \(error.localizedDescription)"
                    print("❌ LiveAuthManager: E-Mail Registrierung Fehler: \(error.localizedDescription)")
                    completion(false, self.errorMessage)
                }
            }
        }
    }
    
    /// Login mit SMS OTP
    func login(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        print("📱 LiveAuthManager: Login starten für: \(phoneNumber)")
        
        // Validiere Telefonnummer
        guard isValidPhoneNumber(phoneNumber) else {
            print("❌ LiveAuthManager: Ungültige Telefonnummer")
            completion(false, "Ungültige Telefonnummer")
            return
        }
        
        // Formatiere die Telefonnummer für Supabase (E.164-Format)
        let formattedPhoneNumber = formatPhoneNumberForSupabase(phoneNumber)
        print("📱 LiveAuthManager: SMS OTP senden für: \(formattedPhoneNumber)")
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await liveSupabaseService.sendLoginOTP(phone: formattedPhoneNumber)
                
                await MainActor.run {
                    self.isLoading = false
                    if success {
                        print("✅ LiveAuthManager: SMS OTP erfolgreich gesendet")
                        completion(true, nil)
                    } else {
                        self.errorMessage = "SMS OTP konnte nicht gesendet werden"
                        completion(false, self.errorMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "SMS OTP Fehler: \(error.localizedDescription)"
                    print("❌ LiveAuthManager: SMS OTP Fehler: \(error.localizedDescription)")
                    completion(false, self.errorMessage)
                }
            }
        }
    }
    
    /// Verifiziert SMS OTP Code
    func verifyCode(phoneNumber: String, code: String, completion: @escaping (Bool, String?) -> Void) {
        // Formatiere die Telefonnummer für Supabase (E.164-Format)
        let formattedPhoneNumber = formatPhoneNumberForSupabase(phoneNumber)
        print("📱 LiveAuthManager: OTP-Verifizierung für: \(formattedPhoneNumber)")
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let user = try await liveSupabaseService.verifyOTP(phone: formattedPhoneNumber, token: code) {
                    await MainActor.run {
                        self.isLoading = false
                        self.currentUser = user
                        self.isAuthenticated = true
                        print("✅ LiveAuthManager: OTP-Verifizierung erfolgreich")
                        completion(true, nil)
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "OTP-Verifizierung fehlgeschlagen"
                        print("❌ LiveAuthManager: OTP-Verifizierung fehlgeschlagen")
                        completion(false, self.errorMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "OTP-Verifizierung Fehler: \(error.localizedDescription)"
                    print("❌ LiveAuthManager: OTP-Verifizierung Fehler: \(error.localizedDescription)")
                    completion(false, self.errorMessage)
                }
            }
        }
    }
    
    /// Registrierung mit SMS OTP
    func sendRegistrationCode(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        print("📱 LiveAuthManager: Registrierung starten für: \(phoneNumber)")
        
        // Validiere Telefonnummer
        guard isValidPhoneNumber(phoneNumber) else {
            print("❌ LiveAuthManager: Ungültige Telefonnummer")
            completion(false, "Ungültige Telefonnummer")
            return
        }
        
        // Formatiere die Telefonnummer für Supabase (E.164-Format)
        let formattedPhoneNumber = formatPhoneNumberForSupabase(phoneNumber)
        print("📱 LiveAuthManager: Registrierung - SMS OTP senden für: \(formattedPhoneNumber)")
        
        print("✅ Telefonnummer-Validierung erfolgreich")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await liveSupabaseService.sendRegistrationOTP(phone: formattedPhoneNumber)
                
                await MainActor.run {
                    self.isLoading = false
                    if success {
                        print("✅ LiveAuthManager: Registrierung SMS OTP erfolgreich gesendet")
                        completion(true, nil)
                    } else {
                        self.errorMessage = "Registrierung SMS OTP konnte nicht gesendet werden"
                        completion(false, self.errorMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Registrierung SMS OTP Fehler: \(error.localizedDescription)"
                    print("❌ LiveAuthManager: Registrierung SMS OTP Fehler: \(error.localizedDescription)")
                    completion(false, self.errorMessage)
                }
            }
        }
    }
    
    /// Verifiziert Registrierung OTP Code
    func completeRegistration(phoneNumber: String, code: String, firstName: String, completion: @escaping (Bool, String?) -> Void) {
        // Validiere Eingaben
        guard !firstName.isEmpty else {
            completion(false, "Vorname ist erforderlich")
            return
        }
        
        // Formatiere die Telefonnummer für Supabase (E.164-Format)
        let formattedPhoneNumber = formatPhoneNumberForSupabase(phoneNumber)
        print("📱 LiveAuthManager: Registrierung abschließen - OTP-Verifizierung für: \(formattedPhoneNumber)")
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Verifiziere OTP mit Metadaten für automatische Profile-Erstellung
                if let user = try await liveSupabaseService.verifyRegistrationOTPWithMetadata(
                    phone: formattedPhoneNumber, 
                    token: code,
                    metadata: [
                        "first_name": AnyJSON.string(firstName),
                        "phone": AnyJSON.string(formattedPhoneNumber)
                    ]
                ) {
                    // ✅ User Profile wird automatisch durch Trigger erstellt!
                    // Keine manuelle Profile-Erstellung mehr nötig
                    
                    await MainActor.run {
                        self.isLoading = false
                        self.currentUser = user
                        self.isAuthenticated = true
                        print("✅ LiveAuthManager: Registrierung erfolgreich abgeschlossen")
                        print("✅ LiveAuthManager: User Profile wurde automatisch erstellt durch Trigger")
                        completion(true, nil)
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Registrierung OTP-Verifizierung fehlgeschlagen"
                        print("❌ LiveAuthManager: Registrierung OTP-Verifizierung fehlgeschlagen")
                        completion(false, self.errorMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Registrierung OTP-Verifizierung Fehler: \(error.localizedDescription)"
                    print("❌ LiveAuthManager: Registrierung OTP-Verifizierung Fehler: \(error.localizedDescription)")
                    completion(false, self.errorMessage)
                }
            }
        }
    }
    
    /// Passwort zurücksetzen
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        print("📧 LiveAuthManager: Passwort Reset starten für: \(email)")
        
        // Validiere E-Mail
        guard isValidEmail(email) else {
            print("❌ LiveAuthManager: Ungültige E-Mail")
            completion(false, "Ungültige E-Mail-Adresse")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Verwende Supabase Auth für Passwort Reset
                let success = try await liveSupabaseService.resetPassword(email: email)
                
                await MainActor.run {
                    self.isLoading = false
                    if success {
                        print("✅ LiveAuthManager: Passwort Reset E-Mail erfolgreich gesendet")
                        completion(true, nil)
                    } else {
                        self.errorMessage = "E-Mail konnte nicht gesendet werden"
                        completion(false, self.errorMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Passwort Reset Fehler: \(error.localizedDescription)"
                    print("❌ LiveAuthManager: Passwort Reset Fehler: \(error.localizedDescription)")
                    completion(false, self.errorMessage)
                }
            }
        }
    }
    
    /// E-Mail-Bestätigung verarbeiten
    func confirmEmail(token: String, completion: @escaping (Bool, String?) -> Void) {
        print("📧 LiveAuthManager: E-Mail-Bestätigung verarbeiten")
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let user = try await liveSupabaseService.confirmEmail(token: token) {
                    await MainActor.run {
                        self.isLoading = false
                        self.currentUser = user
                        self.isAuthenticated = true
                        print("✅ LiveAuthManager: E-Mail-Bestätigung erfolgreich")
                        completion(true, nil)
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "E-Mail-Bestätigung fehlgeschlagen"
                        print("❌ LiveAuthManager: E-Mail-Bestätigung fehlgeschlagen")
                        completion(false, self.errorMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "E-Mail-Bestätigung Fehler: \(error.localizedDescription)"
                    print("❌ LiveAuthManager: E-Mail-Bestätigung Fehler: \(error.localizedDescription)")
                    completion(false, self.errorMessage)
                }
            }
        }
    }
    
    /// Logout
    func logout() {
        print("🚪 LiveAuthManager: Logout")
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    // MARK: - Helper Methods
    
    /// Lädt User Profile
    func getUserProfile(id: UUID) async throws -> UserProfile? {
        return try await liveSupabaseService.getUserProfile(id: id)
    }
    
    // MARK: - Validation Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Phone Number Validation & Formatting
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Formatiere die Telefonnummer für Supabase
        let formatted = formatPhoneNumberForSupabase(phoneNumber)
        
        // Prüfe auf deutsche Telefonnummern im internationalen Format
        let germanPattern = "^\\+49[1-9][0-9]{1,10}$"
        let regex = try? NSRegularExpression(pattern: germanPattern)
        let range = NSRange(location: 0, length: formatted.utf16.count)
        
        return regex?.firstMatch(in: formatted, options: [], range: range) != nil
    }
    
    /// Formatiert die Telefonnummer für Supabase (E.164-Format ohne Leerzeichen)
    private func formatPhoneNumberForSupabase(_ phoneNumber: String) -> String {
        print("🔧 formatPhoneNumberForSupabase: Input: '\(phoneNumber)'")
        
        // Entferne alle Leerzeichen und Sonderzeichen außer +
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "/", with: "")
        
        print("🔧 formatPhoneNumberForSupabase: Cleaned: '\(cleaned)'")
        
        var result: String
        
        // Konvertiere deutsche Nummern ins internationale E.164-Format
        if cleaned.hasPrefix("0") {
            // 0123 456 7890 -> +491234567890
            result = "+49" + String(cleaned.dropFirst(1))
            print("🔧 formatPhoneNumberForSupabase: German format (0...): '\(result)'")
        } else if cleaned.hasPrefix("49") && !cleaned.hasPrefix("+49") {
            // 491234567890 -> +491234567890
            result = "+" + cleaned
            print("🔧 formatPhoneNumberForSupabase: International format (49...): '\(result)'")
        } else if cleaned.hasPrefix("+49") {
            // +49 123 456 7890 -> +491234567890
            result = cleaned
            print("🔧 formatPhoneNumberForSupabase: Already E.164 format (+49...): '\(result)'")
        } else {
            // Fallback: Versuche als deutsche Nummer zu behandeln
            result = "+49" + cleaned
            print("🔧 formatPhoneNumberForSupabase: Fallback format: '\(result)'")
        }
        
        print("🔧 formatPhoneNumberForSupabase: Final result: '\(result)'")
        return result
    }
}
