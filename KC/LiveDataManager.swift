//
//  LiveDataManager.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import Foundation
import SwiftData

// MARK: - Live Data Manager
class LiveDataManager: ObservableObject {
    static let shared = LiveDataManager()
    
    private let liveSupabaseService = LiveSupabaseService()
    
    private init() {
        print("🚀 LiveDataManager: Initialisiert mit echter Supabase-Integration")
    }
    
    // MARK: - Beer Sessions
    
    /// Erstellt Beer Session
    func createBeerSession(
        userId: UUID,
        locationId: UUID,
        duration: String,
        message: String,
        latitude: Double?,
        longitude: Double?,
        beerCount: Int
    ) async {
        print("🍺 LiveDataManager: Beer Session erstellen für User: \(userId)")
        
        let beerSession = BeerSession(
            id: UUID(),
            userId: userId,
            locationId: locationId,
            duration: duration,
            startedAt: Date(),
            endsAt: calculateEndTime(duration: duration),
            status: "active",
            message: message,
            latitude: latitude,
            longitude: longitude,
            beerCount: beerCount
        )
        
        do {
            _ = try await liveSupabaseService.createBeerSession(session: beerSession)
            print("✅ LiveDataManager: Beer Session erfolgreich erstellt")
        } catch {
            print("❌ LiveDataManager: Beer Session erstellen Fehler: \(error.localizedDescription)")
        }
    }
    
    /// Lädt aktive Beer Sessions
    func getActiveBeerSessions() async -> [BeerSession] {
        print("🍺 LiveDataManager: Aktive Beer Sessions laden")
        
        do {
            // Für jetzt geben wir eine leere Liste zurück, da wir keine spezifische Methode haben
            // In einer echten Implementierung würde hier eine spezielle Methode für aktive Sessions aufgerufen
            print("✅ LiveDataManager: 0 aktive Beer Sessions geladen (Mock)")
            return []
        } catch {
            print("❌ LiveDataManager: Beer Sessions laden Fehler: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Friendships
    
    /// Erstellt Freundschaftsanfrage
    func createFriendship(userId: UUID, friendId: UUID) async {
        print("👥 LiveDataManager: Freundschaft erstellen: \(userId) -> \(friendId)")
        
        let friendship = Friendship(
            id: UUID(),
            userId: userId,
            friendId: friendId,
            status: "pending",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            _ = try await liveSupabaseService.createFriendship(friendship: friendship)
            print("✅ LiveDataManager: Freundschaft erfolgreich erstellt")
        } catch {
            print("❌ LiveDataManager: Freundschaft erstellen Fehler: \(error.localizedDescription)")
        }
    }
    
    /// Sucht Benutzer nach QR-Code und erstellt Freundschaftsanfrage
    func addFriendByQRCode(qrCode: String, currentUserId: UUID) async throws -> UserProfile? {
        print("🔍 LiveDataManager: Freund hinzufügen via QR-Code: \(qrCode)")
        
        do {
            // Für jetzt geben wir einen Mock-User zurück, da die QR-Code-Suche noch nicht implementiert ist
            print("❌ LiveDataManager: QR-Code-Suche noch nicht implementiert")
            throw NSError(domain: "NotImplemented", code: 501, userInfo: [NSLocalizedDescriptionKey: "QR-Code-Suche noch nicht implementiert"])
            
        } catch {
            print("❌ LiveDataManager: Freund hinzufügen via QR-Code Fehler: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Lädt Freundschaften
    func getFriendships(userId: UUID) async -> [Friendship] {
        print("👥 LiveDataManager: Freundschaften laden für User: \(userId)")
        
        do {
            let friendships = try await liveSupabaseService.getFriendships(userId: userId)
            print("✅ LiveDataManager: \(friendships.count) Freundschaften geladen")
            return friendships
        } catch {
            print("❌ LiveDataManager: Freundschaften laden Fehler: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Aktualisiert Freundschaftsstatus
    func updateFriendshipStatus(id: UUID, status: String) async {
        print("👥 LiveDataManager: Freundschaftsstatus aktualisieren: \(id) -> \(status)")
        
        do {
            let updates = ["status": status, "updated_at": Date().ISO8601Format()]
            _ = try await liveSupabaseService.updateFriendship(id: id, updates: updates)
            print("✅ LiveDataManager: Freundschaftsstatus erfolgreich aktualisiert")
        } catch {
            print("❌ LiveDataManager: Freundschaftsstatus aktualisieren Fehler: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Kölsch Locations
    
    /// Lädt Kölsch Locations
    func getKoelschLocations() async -> [KoelschLocation] {
        print("🏪 LiveDataManager: Kölsch Locations laden")
        
        do {
            // Für jetzt geben wir Mock-Locations zurück, da die Methode noch nicht implementiert ist
            print("✅ LiveDataManager: Mock Kölsch Locations geladen")
            return KoelschLocation.mockLocations
        } catch {
            print("❌ LiveDataManager: Kölsch Locations laden Fehler: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    /// Berechnet Endzeit basierend auf Dauer
    private func calculateEndTime(duration: String) -> Date {
        let now = Date()
        let calendar = Calendar.current
        
        switch duration {
        case "30_minutes":
            return calendar.date(byAdding: .minute, value: 30, to: now) ?? now
        case "1_hour":
            return calendar.date(byAdding: .hour, value: 1, to: now) ?? now
        case "2_hours":
            return calendar.date(byAdding: .hour, value: 2, to: now) ?? now
        case "3_hours":
            return calendar.date(byAdding: .hour, value: 3, to: now) ?? now
        default:
            return calendar.date(byAdding: .hour, value: 2, to: now) ?? now
        }
    }
    
    /// Lädt aktuelle Location ID (Mock für jetzt)
    func getCurrentLocationId() -> UUID? {
        // TODO: Implementiere echte Location-Logik
        return UUID() // Mock ID
    }
    
    // MARK: - Model Context (für SwiftData Kompatibilität)
    
    /// Setzt Model Context (für SwiftData Kompatibilität)
    func setModelContext(_ modelContext: ModelContext) {
        print("📱 LiveDataManager: Model Context gesetzt (für SwiftData Kompatibilität)")
        // Diese Methode ist für Kompatibilität mit dem alten DataManager
        // Die echten Daten kommen aus Supabase
    }
    
    /// Lädt Freundschaften für einen User
    func loadFriendships(for userId: UUID) async {
        print("👥 LiveDataManager: Freundschaften laden für User: \(userId)")
        
        do {
            let friendships = try await liveSupabaseService.getFriendships(userId: userId)
            print("✅ LiveDataManager: \(friendships.count) Freundschaften geladen")
            // TODO: Update published properties if needed
        } catch {
            print("❌ LiveDataManager: Fehler beim Laden der Freundschaften: \(error.localizedDescription)")
        }
    }
    
    /// Lädt aktive Beer Sessions für Freunde
    func loadActiveBeerSessions(for friendIds: [UUID]) async -> [BeerSession] {
        print("🍺 LiveDataManager: Aktive Beer Sessions laden für \(friendIds.count) Freunde")

        do {
            // Für jetzt geben wir eine leere Liste zurück, da die Methode noch nicht implementiert ist
            print("✅ LiveDataManager: 0 aktive Beer Sessions geladen (Mock)")
            return []
        } catch {
            print("❌ LiveDataManager: Fehler beim Laden der aktiven Beer Sessions: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Beendet eine Beer Session
    func endBeerSession(_ session: BeerSession) async {
        print("🍺 LiveDataManager: Beer Session beenden: \(session.id)")
        // TODO: Implementiere Session beenden in Supabase
    }
    
    /// Lädt Beer Sessions für einen User
    func loadBeerSessions(for userId: UUID) async {
        print("🍺 LiveDataManager: Beer Sessions laden für User: \(userId)")
        // TODO: Implementiere Beer Sessions laden aus Supabase
    }
}
