//
//  SupabaseConfig.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import Foundation

struct SupabaseConfig {
    // ⚠️ WICHTIG: Ersetze mit deinen echten Supabase-Credentials
    // Diese findest du in deinem Supabase Dashboard unter Settings > API
    // Siehe SUPABASE_LIVE_INTEGRATION.md für detaillierte Anleitung
    static let supabaseURL = "https://nrkjjukeracgbpvwbjam.supabase.co"
    static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ya2pqdWtlcmFjZ2JwdndiamFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNTU2OTAsImV4cCI6MjA3MTYzMTY5MH0.9NtxeNVLNwcTSgNq6ug1aedvvz9oBC3SqRB3sahkhEU"
    
    // TODO: Ersetze die obigen Werte mit deinen echten Supabase-Credentials
    // 1. Gehe zu https://supabase.com und erstelle ein neues Projekt
    // 2. Kopiere die Project URL und den anon public key
    // 3. Ersetze die Werte oben
    
    // Prüfe ob echte Credentials konfiguriert sind
    static var isConfigured: Bool {
        // Die Credentials sind bereits konfiguriert, also immer true zurückgeben
        return true
    }
    
    // Tabellen-Namen
    static let beerSessionsTable = "beer_sessions"
    static let friendshipsTable = "friendships"
    static let userProfilesTable = "user_profiles"
    static let koelschLocationsTable = "koelsch_locations"
    
    // Spalten-Namen
    struct BeerSessionColumns {
        static let id = "id"
        static let userId = "user_id"
        static let locationId = "location_id"
        static let duration = "duration"
        static let startedAt = "started_at"
        static let endsAt = "ends_at"
        static let status = "status"
        static let message = "message"
        static let createdAt = "created_at"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let beerCount = "beer_count"
    }
    
    struct FriendshipColumns {
        static let id = "id"
        static let userId = "user_id"
        static let friendId = "friend_id"
        static let status = "status"
        static let createdAt = "created_at"
        static let updatedAt = "updated_at"
    }
    
    struct UserProfileColumns {
        static let id = "id"
        static let firstName = "first_name"
        static let lastName = "last_name"
        static let username = "username"
        static let avatarUrl = "avatar_url"
        static let createdAt = "created_at"
        static let updatedAt = "updated_at"
    }
    
    struct KoelschLocationColumns {
        static let id = "id"
        static let name = "name"
        static let address = "address"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let priceRange = "price_range"
        static let phone = "phone"
        static let website = "website"
        static let tags = "tags"
        static let createdAt = "created_at"
    }
}
