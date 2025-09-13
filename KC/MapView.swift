//
//  MapView.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: LiveAuthManager
    @StateObject private var locationManager = LocationManager()
    @State private var selectedLocation: KoelschLocation?
    @State private var showingLocationDetail = false
    @State private var showCurrentLocationMarker = false
    
    // SwiftData Queries für echte Daten
    @Query private var beerSessions: [BeerSession]
    @Query private var userProfiles: [UserProfile]
    @Query private var friendships: [Friendship]
    
    // Computed Property für aktive Beer-Sessions der Freunde
    private var activeBeerSessions: [ActiveBeerSession] {
        guard let currentUserId = authManager.currentUser?.id else { return [] }
        
        // Finde alle Freunde des aktuellen Nutzers
        let friendIds = friendships.compactMap { friendship in
            friendship.userId == currentUserId ? friendship.friendId : 
            friendship.friendId == currentUserId ? friendship.userId : nil
        }
        
        // Finde aktive Beer-Sessions der Freunde
        return beerSessions.compactMap { session -> ActiveBeerSession? in
            guard friendIds.contains(session.userId) && session.status == "active" else { return nil }
            
            // Finde den Benutzernamen
            let userName = userProfiles.first { $0.id == session.userId }?.username ?? "Unbekannt"
            
            // Finde den Standortnamen (falls verfügbar)
            let locationName = KoelschLocation.mockLocations.first { 
                $0.latitude == session.latitude && $0.longitude == session.longitude 
            }?.name ?? "Unbekannter Ort"
            
            return ActiveBeerSession(
                id: session.id,
                userId: session.userId,
                userName: userName,
                locationId: session.locationId,
                locationName: locationName,
                coordinate: CLLocationCoordinate2D(
                    latitude: session.latitude ?? 50.9375, 
                    longitude: session.longitude ?? 6.9603
                ),
                duration: session.duration,
                message: session.message ?? "",
                beerCount: session.beerCount,
                startedAt: session.startedAt,
                endsAt: session.endsAt
            )
        }
    }
    
    var body: some View {
        ZStack {
            // Hauptkarte
            Map(position: $locationManager.cameraPosition) {
                ForEach(activeBeerSessions, id: \.id) { session in
                    Annotation(session.userName, coordinate: session.coordinate) {
                        ActiveSessionAnnotationView(session: session)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .mapStyle(.standard(elevation: .realistic))
            .preferredColorScheme(.dark)
            .onTapGesture {
                // Vollbild-Karte entfernt - nur noch Karte Tab verwenden
            }
            .onAppear {
                locationManager.requestLocationPermission()
                // Entfernt: centerMapOnAllLocations() - Karte springt nicht mehr automatisch
            }
            
            // Location permission overlay
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "location.slash")
                            .foregroundColor(.red)
                        Text("Standortzugriff erforderlich")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom, 100)
                }
            }
            
            // Fadenkreuz Button (oben rechts)
            VStack {
                HStack {
                    Spacer()
                    Button(action: centerOnCurrentLocation) {
                        Image(systemName: "scope")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.red)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingLocationDetail) {
            if let location = selectedLocation {
                LocationDetailView(location: location)
            }
        }
    }
    
    // Funktion um die Karte so zu zentrieren, dass alle Standorte sichtbar sind
    private func centerMapOnAllLocations() {
        var allCoordinates: [CLLocationCoordinate2D] = []
        
        // Füge alle aktiven Session-Koordinaten hinzu
        for session in activeBeerSessions {
            allCoordinates.append(session.coordinate)
        }
        
        // Füge alle Kölsch-Location-Koordinaten hinzu
        for location in KoelschLocation.mockLocations {
            allCoordinates.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        guard !allCoordinates.isEmpty else {
            // Fallback: Zentriere auf Köln
            locationManager.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 50.9375, longitude: 6.9603),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            return
        }
        
        // Berechne die Bounding Box
        let latitudes = allCoordinates.map { $0.latitude }
        let longitudes = allCoordinates.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 50.9375
        let maxLat = latitudes.max() ?? 50.9375
        let minLng = longitudes.min() ?? 6.9603
        let maxLng = longitudes.max() ?? 6.9603
        
        let centerLat = (minLat + maxLat) / 2
        let centerLng = (minLng + maxLng) / 2
        
        let latDelta = max(maxLat - minLat, 0.01) * 1.2 // 20% Padding
        let lngDelta = max(maxLng - minLng, 0.01) * 1.2 // 20% Padding
        
        locationManager.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        )
    }
    
    private func centerOnCurrentLocation() {
        print("🎯 MapView: Fadenkreuz geklickt - Standort anfordern")

        // Stoppe alle laufenden Location-Updates
        locationManager.stopLocationUpdates()

        // Fordere nur einmalig die aktuelle Position an
        locationManager.requestCurrentLocation()

        // State Updates auf Main Thread verschieben
        DispatchQueue.main.async {
            self.showCurrentLocationMarker = true
            print("📍 MapView: Marker am aktuellen Standort aktiviert")
        }

        // Warte kurz und setze dann die Region mit engem Zoom
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let location = self.locationManager.location {
                print("🎯 MapView: Karte auf aktuellen Standort zentrieren: \(location.coordinate)")

                // Engerer Zoom für bessere Sicht auf den Standort
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.locationManager.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // Engerer Zoom
                    )
                }

                print("✅ MapView: Karte erfolgreich auf Standort zentriert und eingezoomt")
            } else {
                print("❌ MapView: Kein aktueller Standort verfügbar")
            }
        }
    }
}

struct LocationAnnotationView: View {
    let location: KoelschLocation
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "mug.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.red)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                Text(location.name)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .lineLimit(1)
            }
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: location.id)
    }
}

struct LocationDetailView: View {
    let location: KoelschLocation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(location.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < 4 ? "star.fill" : "star")
                                        .foregroundColor(.red)
                                }
                                Text("4.5")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Address
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.red)
                                Text(location.address)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Image(systemName: "eurosign.circle")
                                    .foregroundColor(.red)
                                Text(location.priceRange)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                ForEach(location.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.2))
                                        .foregroundColor(.red)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Contact Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "phone")
                                    .foregroundColor(.red)
                                Text(location.phone)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.red)
                                Text(location.website)
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct ActiveSessionAnnotationView: View {
    let session: ActiveBeerSession
    
    var body: some View {
        VStack(spacing: 0) {
            // Avatar
            Circle()
                .fill(Color.red)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(session.userName.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            // Beer Count Badge
            Text("\(session.beerCount)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.yellow)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
                .offset(x: 15, y: -15)
            
            // Location Name
            Text(session.locationName)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
                .lineLimit(1)
        }
    }
}

// MARK: - Models

struct ActiveBeerSession: Identifiable {
    let id: UUID
    let userId: UUID
    let userName: String
    let locationId: UUID
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let duration: String
    let message: String
    let beerCount: Int
    let startedAt: Date
    let endsAt: Date
}

#Preview {
    MapView()
}
