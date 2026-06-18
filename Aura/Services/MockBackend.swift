import Foundation
import CoreLocation
import Observation

/// MockBackend stands in for the Node/TypeScript + PostgreSQL backend described in
/// the brief (PostGIS geo queries, pgvector recommendations, WebSocket realtime,
/// StoreKit credits). Everything is in-memory mock data so the app is fully
/// demoable on a simulator with no network, keys, or hardware.
@Observable
@MainActor
final class MockBackend {

    // MARK: Discovery (pgvector-style ranked feed)
    var feed: [Profile]
    var filter: DiscoverFilter = .nearby

    // MARK: Map (PostGIS-style nearby meetups)
    var meetups: [Meetup]
    var selectedMeetupID: UUID?

    // MARK: Realtime chat (WebSocket-style)
    var conversations: [Conversation]

    // MARK: Credit wallet (StoreKit-style)
    var credits: Int = 24
    var ledger: [CreditTransaction]

    let me = (name: "You", city: "Valencia")

    init() {
        feed = MockBackend.seedProfiles()
        meetups = MockBackend.seedMeetups()
        conversations = MockBackend.seedConversations()
        ledger = [
            CreditTransaction(label: "Welcome bonus", amount: 20, date: "Mon"),
            CreditTransaction(label: "Starter pack", amount: 10, date: "Tue"),
            CreditTransaction(label: "Boosted profile", amount: -6, date: "Wed"),
        ]
    }

    // Ranked feed per segment.
    var visibleFeed: [Profile] {
        switch filter {
        case .nearby: return feed.sorted { $0.distanceKm < $1.distanceKm }
        case .interests: return feed.sorted { $0.matchPercent > $1.matchPercent }
        case .new: return feed
        }
    }

    // MARK: Discover actions
    /// Like / pass removes the top card (optimistic, like a real swipe stack).
    func consumeTop() {
        guard !feed.isEmpty else { feed = MockBackend.seedProfiles(); return }
        let top = visibleFeed.first
        feed.removeAll { $0.id == top?.id }
        if feed.isEmpty { feed = MockBackend.seedProfiles() } // loop for demo
    }

    // MARK: Map actions
    var selectedMeetup: Meetup? {
        meetups.first { $0.id == selectedMeetupID }
    }

    func selectMeetup(_ id: UUID) { selectedMeetupID = id }

    /// Reserve a spot: spends credits and marks joined (StoreKit credit economy).
    @discardableResult
    func joinSelectedMeetup() -> Bool {
        guard let idx = meetups.firstIndex(where: { $0.id == selectedMeetupID }) else { return false }
        if meetups[idx].joined { return true }
        let cost = meetups[idx].creditCost
        guard credits >= cost else { return false }
        credits -= cost
        meetups[idx].joined = true
        ledger.insert(CreditTransaction(label: "Joined \(meetups[idx].title)", amount: -cost, date: "Now"), at: 0)
        return true
    }

    func buyCredits(_ amount: Int) {
        credits += amount
        ledger.insert(CreditTransaction(label: "Purchased \(amount) credits", amount: amount, date: "Now"), at: 0)
    }

    // MARK: Chat actions
    func send(_ text: String, to convoID: UUID) {
        guard let i = conversations.firstIndex(where: { $0.id == convoID }) else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let msg = ChatMessage(id: UUID(), text: trimmed, fromMe: true, time: "Now", delivered: true)
        conversations[i].messages.append(msg)
        conversations[i].lastMessage = trimmed
    }

    // MARK: Seed data
    static func seedProfiles() -> [Profile] {
        [
            Profile(id: UUID(), name: "Elena", age: 28, distanceKm: 2,
                    interests: ["Ceramics", "Sunrise Hikes", "Poetry"],
                    bio: "Seeking slow mornings, deep conversations, and someone who...",
                    matchPercent: 98, photo: "p_elena",
                    coordinate: .init(latitude: 39.4699, longitude: -0.3763)),
            Profile(id: UUID(), name: "Mateo", age: 31, distanceKm: 1,
                    interests: ["Vinyl", "Cooking", "Street Photography"],
                    bio: "Will trade a home-cooked paella for a good record recommendation.",
                    matchPercent: 92, photo: "p_mateo",
                    coordinate: .init(latitude: 39.4620, longitude: -0.3500)),
            Profile(id: UUID(), name: "Sofia", age: 26, distanceKm: 3,
                    interests: ["Climbing", "Jazz", "Watercolor"],
                    bio: "Weekends are for boulders and bossa nova. Looking for a belay partner.",
                    matchPercent: 88, photo: "p_sofia",
                    coordinate: .init(latitude: 39.4750, longitude: -0.3900)),
            Profile(id: UUID(), name: "Liam", age: 30, distanceKm: 4,
                    interests: ["Cycling", "Espresso", "Architecture"],
                    bio: "Mapping the city one cortado at a time. Tell me your favorite corner.",
                    matchPercent: 84, photo: "p_liam",
                    coordinate: .init(latitude: 39.4550, longitude: -0.3600)),
        ]
    }

    static func seedMeetups() -> [Meetup] {
        [
            Meetup(id: UUID(), title: "Coffee & Code", category: "SOCIAL MEETUP",
                   venue: "Artisanal Brews Cafe", time: "10:00 AM", distanceMi: 0.4,
                   attendeeCount: 15, attendeePhotos: ["a1", "a2", "a3"],
                   coordinate: .init(latitude: 39.4705, longitude: -0.3758), creditCost: 4),
            Meetup(id: UUID(), title: "Golden Hour Sketch", category: "CREATIVE",
                   venue: "Turia Gardens", time: "6:30 PM", distanceMi: 0.9,
                   attendeeCount: 8, attendeePhotos: ["a2", "a3"],
                   coordinate: .init(latitude: 39.4640, longitude: -0.3690), creditCost: 3),
            Meetup(id: UUID(), title: "Sunset Run Club", category: "WELLNESS",
                   venue: "Malvarrosa Beach", time: "7:15 PM", distanceMi: 1.6,
                   attendeeCount: 22, attendeePhotos: ["a1", "a3"],
                   coordinate: .init(latitude: 39.4720, longitude: -0.3250), creditCost: 5),
        ]
    }

    static func seedConversations() -> [Conversation] {
        [
            Conversation(id: UUID(), name: "Alex", avatar: "p_alex", activeNow: true,
                         lastMessage: "2pm is perfect. It's a date!",
                         messages: [
                            ChatMessage(id: UUID(), text: "Hey! I was just thinking about that coffee spot we mentioned the other day. ☕️", fromMe: false, time: "10:40 AM"),
                            ChatMessage(id: UUID(), text: "Are you still free to meet up this weekend? I'd love to catch up properly.", fromMe: false, time: "10:41 AM"),
                            ChatMessage(id: UUID(), text: "Totally! I've been craving their almond croissants. Saturday afternoon works best for me. Does 2pm sound okay? 🥐", fromMe: true, time: "10:45 AM"),
                            ChatMessage(id: UUID(), text: "2pm is perfect. It's a date! Can't wait to hear about your new project.", fromMe: false, time: "10:46 AM"),
                         ]),
            Conversation(id: UUID(), name: "Elena", avatar: "p_elena", activeNow: false,
                         lastMessage: "The ceramics studio has an open night Thursday!",
                         messages: [
                            ChatMessage(id: UUID(), text: "Loved your poetry pick from the feed.", fromMe: true, time: "Yesterday"),
                            ChatMessage(id: UUID(), text: "The ceramics studio has an open night Thursday!", fromMe: false, time: "Yesterday"),
                         ]),
            Conversation(id: UUID(), name: "Mateo", avatar: "p_mateo", activeNow: true,
                         lastMessage: "Bringing the vinyl, you bring the paella?",
                         messages: [
                            ChatMessage(id: UUID(), text: "Bringing the vinyl, you bring the paella?", fromMe: false, time: "9:02 AM"),
                         ]),
        ]
    }
}
