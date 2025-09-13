//
//  Item.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import Foundation
import SwiftData

@Model
final class BeerSession {
    var id: UUID
    var userId: UUID
    var locationId: UUID
    var duration: String
    var startedAt: Date
    var endsAt: Date
    var status: String
    var message: String?
    var createdAt: Date
    var latitude: Double?
    var longitude: Double?
    var beerCount: Int
    
    init(id: UUID = UUID(), userId: UUID, locationId: UUID, duration: String, startedAt: Date, endsAt: Date, status: String, message: String? = nil, createdAt: Date = Date(), latitude: Double? = nil, longitude: Double? = nil, beerCount: Int = 0) {
        self.id = id
        self.userId = userId
        self.locationId = locationId
        self.duration = duration
        self.startedAt = startedAt
        self.endsAt = endsAt
        self.status = status
        self.message = message
        self.createdAt = createdAt
        self.latitude = latitude
        self.longitude = longitude
        self.beerCount = beerCount
    }
    
    // MARK: - Supabase Integration
    
    func toSupabaseDict() -> [String: Any] {
        return [
            "id": id.uuidString,
            "user_id": userId.uuidString,
            "location_id": locationId.uuidString,
            "duration": duration,
            "started_at": startedAt.ISO8601Format(),
            "ends_at": endsAt.ISO8601Format(),
            "status": status,
            "message": message ?? "",
            "created_at": createdAt.ISO8601Format(),
            "latitude": latitude ?? 0.0,
            "longitude": longitude ?? 0.0,
            "beer_count": beerCount
        ]
    }
    
    static func fromSupabaseDict(_ dict: [String: Any]) -> BeerSession? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let userIdString = dict["user_id"] as? String,
              let userId = UUID(uuidString: userIdString),
              let locationIdString = dict["location_id"] as? String,
              let locationId = UUID(uuidString: locationIdString),
              let duration = dict["duration"] as? String,
              let startedAtString = dict["started_at"] as? String,
              let startedAt = ISO8601DateFormatter().date(from: startedAtString),
              let endsAtString = dict["ends_at"] as? String,
              let endsAt = ISO8601DateFormatter().date(from: endsAtString),
              let status = dict["status"] as? String,
              let message = dict["message"] as? String,
              let createdAtString = dict["created_at"] as? String,
              let createdAt = ISO8601DateFormatter().date(from: createdAtString) else {
            return nil
        }
        
        let latitude = dict["latitude"] as? Double
        let longitude = dict["longitude"] as? Double
        let beerCount = dict["beer_count"] as? Int ?? 0
        
        return BeerSession(
            id: id,
            userId: userId,
            locationId: locationId,
            duration: duration,
            startedAt: startedAt,
            endsAt: endsAt,
            status: status,
            message: message.isEmpty ? nil : message,
            createdAt: createdAt,
            latitude: latitude,
            longitude: longitude,
            beerCount: beerCount
        )
    }
}

@Model
final class UserProfile {
    var id: UUID
    var firstName: String
    var lastName: String?
    var username: String?
    var avatarUrl: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), firstName: String, lastName: String? = nil, username: String? = nil, avatarUrl: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Supabase Integration
    
    func toSupabaseDict() -> [String: Any] {
        return [
            "id": id.uuidString,
            "first_name": firstName,
            "last_name": lastName as Any,
            "username": username as Any,
            "avatar_url": avatarUrl as Any,
            "created_at": createdAt.ISO8601Format(),
            "updated_at": updatedAt.ISO8601Format()
        ]
    }
    
    static func fromSupabaseDict(_ dict: [String: Any]) -> UserProfile? {
        guard let idString = dict["id"] as? String, let id = UUID(uuidString: idString),
              let firstName = dict["first_name"] as? String,
              let createdAtString = dict["created_at"] as? String, let createdAt = ISO8601DateFormatter().date(from: createdAtString),
              let updatedAtString = dict["updated_at"] as? String, let updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
        else { return nil }
        
        let lastName = dict["last_name"] as? String
        let username = dict["username"] as? String
        let avatarUrl = dict["avatar_url"] as? String
        
        return UserProfile(id: id, firstName: firstName, lastName: lastName, username: username, avatarUrl: avatarUrl, createdAt: createdAt, updatedAt: updatedAt)
    }
}

@Model
final class Friendship {
    var id: UUID
    var userId: UUID
    var friendId: UUID
    var status: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), userId: UUID, friendId: UUID, status: String = "pending", createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.friendId = friendId
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Supabase Integration
    
    func toSupabaseDict() -> [String: Any] {
        return [
            "id": id.uuidString,
            "user_id": userId.uuidString,
            "friend_id": friendId.uuidString,
            "status": status,
            "created_at": createdAt.ISO8601Format(),
            "updated_at": updatedAt.ISO8601Format()
        ]
    }
    
    static func fromSupabaseDict(_ dict: [String: Any]) -> Friendship? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let userIdString = dict["user_id"] as? String,
              let userId = UUID(uuidString: userIdString),
              let friendIdString = dict["friend_id"] as? String,
              let friendId = UUID(uuidString: friendIdString),
              let status = dict["status"] as? String,
              let createdAtString = dict["created_at"] as? String,
              let createdAt = ISO8601DateFormatter().date(from: createdAtString),
              let updatedAtString = dict["updated_at"] as? String,
              let updatedAt = ISO8601DateFormatter().date(from: updatedAtString) else {
            return nil
        }
        
        return Friendship(
            id: id,
            userId: userId,
            friendId: friendId,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}


// Legacy Item class für Kompatibilität
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

// MARK: - Event Model

@Model
final class Event {
    var id: UUID
    var title: String
    var eventDescription: String?
    var location: String?
    var startDate: Date
    var endDate: Date
    var isPublic: Bool
    var maxAttendees: Int?
    var attendeeCount: Int
    var createdBy: UUID
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String, eventDescription: String? = nil, location: String? = nil, startDate: Date, endDate: Date, isPublic: Bool = true, maxAttendees: Int? = nil, attendeeCount: Int = 0, createdBy: UUID, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.isPublic = isPublic
        self.maxAttendees = maxAttendees
        self.attendeeCount = attendeeCount
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Supabase Integration
    
    func toSupabaseDict() -> [String: Any] {
        return [
            "id": id.uuidString,
            "title": title,
            "description": eventDescription as Any,
            "location": location as Any,
            "start_date": startDate.ISO8601Format(),
            "end_date": endDate.ISO8601Format(),
            "is_public": isPublic,
            "max_attendees": maxAttendees as Any,
            "attendee_count": attendeeCount,
            "created_by": createdBy.uuidString,
            "created_at": createdAt.ISO8601Format(),
            "updated_at": updatedAt.ISO8601Format()
        ]
    }
    
    static func fromSupabaseDict(_ dict: [String: Any]) -> Event? {
        guard let idString = dict["id"] as? String, let id = UUID(uuidString: idString),
              let title = dict["title"] as? String,
              let startDateString = dict["start_date"] as? String, let startDate = ISO8601DateFormatter().date(from: startDateString),
              let endDateString = dict["end_date"] as? String, let endDate = ISO8601DateFormatter().date(from: endDateString),
              let isPublic = dict["is_public"] as? Bool,
              let attendeeCount = dict["attendee_count"] as? Int,
              let createdByString = dict["created_by"] as? String, let createdBy = UUID(uuidString: createdByString),
              let createdAtString = dict["created_at"] as? String, let createdAt = ISO8601DateFormatter().date(from: createdAtString),
              let updatedAtString = dict["updated_at"] as? String, let updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
        else { return nil }
        
        let eventDescription = dict["description"] as? String
        let location = dict["location"] as? String
        let maxAttendees = dict["max_attendees"] as? Int
        
        return Event(id: id, title: title, eventDescription: eventDescription, location: location, startDate: startDate, endDate: endDate, isPublic: isPublic, maxAttendees: maxAttendees, attendeeCount: attendeeCount, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt)
    }
}
