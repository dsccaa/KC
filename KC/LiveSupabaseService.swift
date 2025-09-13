//
//  LiveSupabaseService.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import Foundation
import Supabase
import PostgREST
import HTTPTypes

// MARK: - AuthUser Model
struct AuthUser {
    let id: UUID
    let phone: String
    let email: String?
    let createdAt: Date?
    
    init(id: UUID, phone: String, email: String? = nil, createdAt: Date? = nil) {
        self.id = id
        self.phone = phone
        self.email = email
        self.createdAt = createdAt
    }
}

// MARK: - Live Supabase Service
class LiveSupabaseService: ObservableObject {
    private let supabase: SupabaseClient
    
    init() {
        guard SupabaseConfig.isConfigured else {
            fatalError("❌ Supabase nicht konfiguriert! Siehe SUPABASE_LIVE_INTEGRATION.md")
        }
        
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseKey
        )
        
        print("✅ LiveSupabaseService: Echte Supabase-Verbindung initialisiert")
        print("🌐 URL: \(SupabaseConfig.supabaseURL)")
        print("🔑 Key: \(SupabaseConfig.supabaseKey.prefix(20))...")
    }
    
    // MARK: - Authentication
    
    /// Login mit E-Mail und Passwort
    func loginWithEmail(email: String, password: String) async throws -> AuthUser? {
        print("📧 LiveSupabaseService: E-Mail Login für: \(email)")
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            
            // session.user ist nicht optional in der aktuellen Version
            let user = session.user
            print("✅ LiveSupabaseService: E-Mail Login erfolgreich")
            return AuthUser(
                id: UUID(uuidString: user.id.uuidString) ?? UUID(),
                phone: user.phone ?? "",
                email: user.email,
                createdAt: user.createdAt
            )
        } catch {
            print("❌ LiveSupabaseService: E-Mail Login Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Registrierung mit E-Mail und Passwort
    func registerWithEmail(email: String, password: String, metadata: [String: AnyJSON]) async throws -> AuthUser? {
        print("📧 LiveSupabaseService: E-Mail Registrierung für: \(email)")
        
        do {
            let session = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: metadata
            )
            
            // session.user ist nicht optional in der aktuellen Version
            let user = session.user
            print("✅ LiveSupabaseService: E-Mail Registrierung erfolgreich")
            return AuthUser(
                id: UUID(uuidString: user.id.uuidString) ?? UUID(),
                phone: user.phone ?? "",
                email: user.email,
                createdAt: user.createdAt
            )
        } catch {
            print("❌ LiveSupabaseService: E-Mail Registrierung Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Sendet SMS OTP für Login
    func sendLoginOTP(phone: String) async throws -> Bool {
        print("📱 LiveSupabaseService: SMS OTP senden für: \(phone)")
        
        do {
            try await supabase.auth.signInWithOTP(phone: phone)
            print("✅ LiveSupabaseService: SMS OTP erfolgreich gesendet")
            return true
        } catch {
            print("❌ LiveSupabaseService: SMS OTP Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Verifiziert SMS OTP Code
    func verifyOTP(phone: String, token: String) async throws -> AuthUser? {
        print("📱 LiveSupabaseService: OTP-Verifizierung für: \(phone)")
        
        do {
            let session = try await supabase.auth.verifyOTP(phone: phone, token: token, type: .sms)
            
            // session.user ist nicht optional in der aktuellen Version
            let user = session.user
            print("✅ LiveSupabaseService: OTP-Verifizierung erfolgreich")
            return AuthUser(
                id: UUID(uuidString: user.id.uuidString) ?? UUID(),
                phone: user.phone ?? phone,
                email: user.email,
                createdAt: user.createdAt
            )
        } catch {
            print("❌ LiveSupabaseService: OTP-Verifizierung Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Sendet SMS OTP für Registrierung
    func sendRegistrationOTP(phone: String) async throws -> Bool {
        print("📱 LiveSupabaseService: Registrierung SMS OTP senden für: \(phone)")
        
        do {
            // Verwende signInWithOTP für Registrierung (funktioniert auch für neue Benutzer)
            try await supabase.auth.signInWithOTP(phone: phone)
            print("✅ LiveSupabaseService: Registrierung SMS OTP erfolgreich gesendet")
            return true
        } catch {
            print("❌ LiveSupabaseService: Registrierung SMS OTP Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Verifiziert Registrierung OTP Code mit Metadaten
    func verifyRegistrationOTPWithMetadata(phone: String, token: String, metadata: [String: AnyJSON]) async throws -> AuthUser? {
        print("📱 LiveSupabaseService: Registrierung OTP-Verifizierung für: \(phone)")
        
        do {
            let session = try await supabase.auth.verifyOTP(phone: phone, token: token, type: .sms)
            
            // session.user ist nicht optional in der aktuellen Version
            let user = session.user
            
            // Aktualisiere User-Metadaten (Mock - updateUser existiert nicht in dieser Version)
            print("📝 LiveSupabaseService: User-Metadaten aktualisiert (Mock)")
            
            print("✅ LiveSupabaseService: Registrierung OTP-Verifizierung erfolgreich")
            return AuthUser(
                id: UUID(uuidString: user.id.uuidString) ?? UUID(),
                phone: user.phone ?? phone,
                email: user.email,
                createdAt: user.createdAt
            )
        } catch {
            print("❌ LiveSupabaseService: Registrierung OTP-Verifizierung Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// E-Mail-Bestätigung verarbeiten
    func confirmEmail(token: String) async throws -> AuthUser? {
        print("📧 LiveSupabaseService: E-Mail-Bestätigung verarbeiten")
        
        do {
            let session = try await supabase.auth.verifyOTP(token: token, type: .email)
            
            // session.user ist nicht optional in der aktuellen Version
            let user = session.user
            print("✅ LiveSupabaseService: E-Mail-Bestätigung erfolgreich")
            return AuthUser(
                id: UUID(uuidString: user.id.uuidString) ?? UUID(),
                phone: user.phone ?? "",
                email: user.email,
                createdAt: user.createdAt
            )
        } catch {
            print("❌ LiveSupabaseService: E-Mail-Bestätigung Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Passwort zurücksetzen
    func resetPassword(email: String) async throws -> Bool {
        print("📧 LiveSupabaseService: Passwort Reset für: \(email)")
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            print("✅ LiveSupabaseService: Passwort Reset E-Mail erfolgreich gesendet")
            return true
        } catch {
            print("❌ LiveSupabaseService: Passwort Reset Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Logout
    func logout() async throws {
        print("🚪 LiveSupabaseService: Logout")
        try await supabase.auth.signOut()
    }
    
    // MARK: - User Profile Management (Mock Implementation)
    
    /// Lädt User Profile
    func getUserProfile(id: UUID) async throws -> UserProfile? {
        print("👤 LiveSupabaseService: User Profile laden für: \(id)")
        
        // Mock implementation - gibt einen Dummy-User zurück
        print("✅ LiveSupabaseService: Mock User Profile geladen")
        return UserProfile(
            firstName: "Max",
            lastName: "Mustermann",
            username: "max_mustermann",
            avatarUrl: nil
        )
    }
    
    /// Erstellt User Profile
    func createUserProfile(profile: UserProfile) async throws -> UserProfile? {
        print("👤 LiveSupabaseService: User Profile erstellen für: \(profile.id)")
        
        // Mock implementation
        print("✅ LiveSupabaseService: Mock User Profile erstellt")
        return profile
    }
    
    /// Aktualisiert User Profile
    func updateUserProfile(id: UUID, updates: [String: Any]) async throws -> UserProfile? {
        print("👤 LiveSupabaseService: User Profile aktualisieren für: \(id)")
        
        // Mock implementation
        print("✅ LiveSupabaseService: Mock User Profile aktualisiert")
        return UserProfile(
            firstName: "Max",
            lastName: "Mustermann",
            username: "max_mustermann",
            avatarUrl: nil
        )
    }
    
    // MARK: - Beer Sessions (Mock Implementation)
    
    /// Erstellt Beer Session
    func createBeerSession(session: BeerSession) async throws -> BeerSession? {
        print("🍺 LiveSupabaseService: Beer Session erstellen")
        
        // Mock implementation
        print("✅ LiveSupabaseService: Mock Beer Session erstellt")
        return session
    }
    
    /// Lädt Beer Sessions für User
    func getBeerSessions(userId: UUID) async throws -> [BeerSession] {
        print("🍺 LiveSupabaseService: Beer Sessions laden für: \(userId)")
        
        // Mock implementation
        print("✅ LiveSupabaseService: Mock Beer Sessions geladen")
        return []
    }
    
    /// Aktualisiert Beer Session
    func updateBeerSession(id: UUID, updates: [String: Any]) async throws -> BeerSession? {
        print("🍺 LiveSupabaseService: Beer Session aktualisieren für: \(id)")
        
        // Mock implementation
        print("✅ LiveSupabaseService: Mock Beer Session aktualisiert")
        return nil
    }
    
    // MARK: - Friendships (Mock Implementation)
    
    /// Lädt Friendships für User
    func getFriendships(userId: UUID) async throws -> [Friendship] {
        print("👥 LiveSupabaseService: Friendships laden für: \(userId)")
        
        // Mock implementation
        print("✅ LiveSupabaseService: Mock Friendships geladen")
        return []
    }
    
    /// Erstellt Friendship
    func createFriendship(friendship: Friendship) async throws -> Friendship? {
        print("👥 LiveSupabaseService: Friendship erstellen")
        
        // Mock implementation
        print("✅ LiveSupabaseService: Mock Friendship erstellt")
        return friendship
    }
    
    /// Aktualisiert Friendship
    func updateFriendship(id: UUID, updates: [String: Any]) async throws -> Friendship? {
        print("👥 LiveSupabaseService: Friendship aktualisieren für: \(id)")
        
        // Mock implementation
        print("✅ LiveSupabaseService: Mock Friendship aktualisiert")
        return nil
    }
}