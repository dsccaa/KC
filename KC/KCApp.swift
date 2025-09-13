//
//  KCApp.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import SwiftUI
import SwiftData

@main
struct KCApp: App {
    @StateObject private var authManager: LiveAuthManager = {
        if SupabaseConfig.isConfigured {
            print("✅ KCApp: Verwende LiveAuthManager mit echter Supabase-Integration")
            return LiveAuthManager()
        } else {
            print("⚠️ KCApp: Supabase nicht konfiguriert, verwende RealAuthManager (Mock)")
            return LiveAuthManager() // Fallback zu Mock
        }
    }()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BeerSession.self,
            UserProfile.self,
            Friendship.self,
            Item.self, // Legacy für Kompatibilität
        ])
        
        // Verwende eine neue Datenbank-URL um Schema-Konflikte zu vermeiden
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let newDatabaseURL = documentsPath.appendingPathComponent("KC_v2.sqlite")
        
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            url: newDatabaseURL,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Falls das fehlschlägt, verwende In-Memory Storage als Fallback
            print("Failed to create persistent ModelContainer: \(error)")
            print("Falling back to in-memory storage...")
            
            let fallbackConfiguration = ModelConfiguration(
                schema: schema, 
                isStoredInMemoryOnly: true
            )
            
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even with fallback: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
