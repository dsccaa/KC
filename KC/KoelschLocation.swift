//
//  KoelschLocation.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import Foundation
import CoreLocation

struct KoelschLocation: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let priceRange: String
    let phone: String
    let website: String
    let tags: [String]
    let createdAt: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Supabase Integration
    
    func toSupabaseDict() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "address": address,
            "latitude": latitude,
            "longitude": longitude,
            "price_range": priceRange,
            "phone": phone,
            "website": website,
            "tags": tags,
            "created_at": createdAt.ISO8601Format()
        ]
    }
    
    static func fromSupabaseDict(_ dict: [String: Any]) -> KoelschLocation? {
        guard let idString = dict["id"] as? String, let id = UUID(uuidString: idString),
              let name = dict["name"] as? String,
              let address = dict["address"] as? String,
              let latitude = dict["latitude"] as? Double,
              let longitude = dict["longitude"] as? Double,
              let priceRange = dict["price_range"] as? String,
              let phone = dict["phone"] as? String,
              let website = dict["website"] as? String,
              let tags = dict["tags"] as? [String],
              let createdAtString = dict["created_at"] as? String, let createdAt = ISO8601DateFormatter().date(from: createdAtString)
        else { return nil }
        
        return KoelschLocation(
            id: id,
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            priceRange: priceRange,
            phone: phone,
            website: website,
            tags: tags,
            createdAt: createdAt
        )
    }
    
    // Mock-Daten für Entwicklung
    static let mockLocations = [
        KoelschLocation(
            id: UUID(),
            name: "Früh am Dom",
            address: "Am Hof 12-14, 50667 Köln",
            latitude: 50.9413,
            longitude: 6.9583,
            priceRange: "€€",
            phone: "+49 221 2613215",
            website: "https://www.frueh.de",
            tags: ["Traditionell", "Zentral", "Touristisch"],
            createdAt: Date().addingTimeInterval(-2592000)
        ),
        KoelschLocation(
            id: UUID(),
            name: "Gaffel am Dom",
            address: "Bahnhofsvorplatz 1, 50667 Köln",
            latitude: 50.9408,
            longitude: 6.9578,
            priceRange: "€€",
            phone: "+49 221 2577762",
            website: "https://www.gaffel.de",
            tags: ["Zentral", "Bahnhofsnähe", "Groß"],
            createdAt: Date().addingTimeInterval(-2592000)
        ),
        KoelschLocation(
            id: UUID(),
            name: "Päffgen",
            address: "Friesenstraße 64-66, 50670 Köln",
            latitude: 50.9367,
            longitude: 6.9467,
            priceRange: "€€€",
            phone: "+49 221 135461",
            website: "https://www.paeffgen.de",
            tags: ["Traditionell", "Lokal", "Authentisch"],
            createdAt: Date().addingTimeInterval(-2592000)
        ),
        KoelschLocation(
            id: UUID(),
            name: "Sion",
            address: "Unter Taschenmacher 5-7, 50667 Köln",
            latitude: 50.9389,
            longitude: 6.9603,
            priceRange: "€€",
            phone: "+49 221 2578540",
            website: "https://www.sion.de",
            tags: ["Traditionell", "Altstadt", "Klein"],
            createdAt: Date().addingTimeInterval(-2592000)
        ),
        KoelschLocation(
            id: UUID(),
            name: "Brauerei zur Malzmühle",
            address: "Heumarkt 6, 50667 Köln",
            latitude: 50.9375,
            longitude: 6.9592,
            priceRange: "€€",
            phone: "+49 221 210118",
            website: "https://www.muehlen-koelsch.de",
            tags: ["Traditionell", "Heumarkt", "Groß"],
            createdAt: Date().addingTimeInterval(-2592000)
        )
    ]
}
