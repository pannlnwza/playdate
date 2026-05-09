import Foundation

extension Event {
    static let mockEvents: [Event] = {
        let cal = Calendar.current
        let now = Date()
        func dateAt(daysAhead: Int, hour: Int, minute: Int = 0) -> Date {
            cal.date(byAdding: .day, value: daysAhead, to: now)
                .flatMap { cal.date(bySettingHour: hour, minute: minute, second: 0, of: $0) } ?? now
        }

        return [
            Event(
                id: "feat-1",
                title: "Park Picnic Playdate",
                description: "Family picnic with games, snacks, and crafts",
                locationName: "Central Park",
                latitude: 40.785,
                longitude: -73.968,
                dateTime: dateAt(daysAhead: 3, hour: 10),
                organizerId: "p1",
                endDateTime: dateAt(daysAhead: 3, hour: 12),
                minAge: 3,
                maxAge: 6,
                category: .outdoors,
                attendingFamilyCount: 12,
                isFeatured: true
            ),
            Event(
                id: "evt-1",
                title: "Toddler Soccer Meetup",
                description: "Beginner soccer for little kickers",
                locationName: "Riverside Fields",
                latitude: 40.801,
                longitude: -73.972,
                dateTime: dateAt(daysAhead: 5, hour: 9),
                organizerId: "p2",
                endDateTime: dateAt(daysAhead: 5, hour: 11),
                minAge: 3,
                maxAge: 5,
                category: .sports,
                attendingFamilyCount: 5
            ),
            Event(
                id: "evt-2",
                title: "Storytelling in the Garden",
                description: "Outdoor reading hour for all ages",
                locationName: "Botanical Gardens",
                latitude: 40.665,
                longitude: -73.963,
                dateTime: dateAt(daysAhead: 8, hour: 14),
                organizerId: "p3",
                endDateTime: dateAt(daysAhead: 8, hour: 15, minute: 30),
                minAge: 2,
                maxAge: 8,
                category: .storytime,
                attendingFamilyCount: 8
            ),
            Event(
                id: "evt-3",
                title: "Arts & Crafts Morning",
                description: "Hands-on art for kids and parents",
                locationName: "Community Center",
                latitude: 40.690,
                longitude: -73.985,
                dateTime: dateAt(daysAhead: 13, hour: 10),
                organizerId: "p4",
                endDateTime: dateAt(daysAhead: 13, hour: 12),
                minAge: 4,
                maxAge: 8,
                category: .arts,
                attendingFamilyCount: 6
            ),
            Event(
                id: "evt-4",
                title: "Music & Movement Class",
                description: "Sing, dance, and play instruments",
                locationName: "Harmony Studio",
                latitude: 40.720,
                longitude: -73.999,
                dateTime: dateAt(daysAhead: 15, hour: 16),
                organizerId: "p5",
                endDateTime: dateAt(daysAhead: 15, hour: 17),
                minAge: 2,
                maxAge: 4,
                category: .music,
                attendingFamilyCount: 4
            ),
            Event(
                id: "evt-5",
                title: "Family Hike Adventure",
                description: "Easy trail walk with photo stops",
                locationName: "Greenwood Trail",
                latitude: 40.658,
                longitude: -73.992,
                dateTime: dateAt(daysAhead: 18, hour: 8),
                organizerId: "p1",
                endDateTime: dateAt(daysAhead: 18, hour: 11),
                minAge: 5,
                maxAge: 12,
                category: .outdoors,
                attendingFamilyCount: 9
            )
        ]
    }()
}
