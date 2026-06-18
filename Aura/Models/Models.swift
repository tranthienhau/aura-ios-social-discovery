import Foundation
import CoreLocation

/// Discovery profile (returned by the recommendation service, ranked by shared
/// interests = the pgvector / "shared frequency" idea in the backend brief).
struct Profile: Identifiable, Equatable {
    let id: UUID
    let name: String
    let age: Int
    let distanceKm: Double
    let interests: [String]
    let bio: String
    let matchPercent: Int
    let photo: String          // asset name in Assets, falls back to gradient
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: Profile, rhs: Profile) -> Bool { lhs.id == rhs.id }
}

/// Discover feed segment.
enum DiscoverFilter: String, CaseIterable, Identifiable {
    case nearby = "Nearby"
    case interests = "Interests"
    case new = "New"
    var id: String { rawValue }
}

/// Time-sensitive meetup pinned on the map.
struct Meetup: Identifiable, Equatable {
    let id: UUID
    let title: String
    let category: String          // e.g. "SOCIAL MEETUP"
    let venue: String
    let time: String
    let distanceMi: Double
    let attendeeCount: Int
    let attendeePhotos: [String]
    let coordinate: CLLocationCoordinate2D
    let creditCost: Int           // credits to reserve a spot
    var joined: Bool = false

    static func == (lhs: Meetup, rhs: Meetup) -> Bool { lhs.id == rhs.id }
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let text: String
    let fromMe: Bool
    let time: String
    var delivered: Bool = true
}

/// A conversation surfaces presence (active now) - the realtime brief.
struct Conversation: Identifiable, Equatable {
    let id: UUID
    let name: String
    let avatar: String
    var activeNow: Bool
    var lastMessage: String
    var messages: [ChatMessage]

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id && lhs.messages == rhs.messages && lhs.activeNow == rhs.activeNow
    }
}

/// In-app credit wallet (StoreKit credit economy, mocked).
struct CreditTransaction: Identifiable {
    let id = UUID()
    let label: String
    let amount: Int               // +purchase, -spend
    let date: String
}
