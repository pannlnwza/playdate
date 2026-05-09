import Foundation

extension Event {
    static let mockEvents: [Event] = {
        let cal = Calendar.current
        let now = Date()
        func date(daysAhead: Int) -> Date {
            cal.date(byAdding: .day, value: daysAhead, to: now) ?? now
        }

        return [
            Event(
                id: "feat-1",
                title: "Park Picnic Playdate",
                location: "Central Park",
                date: date(daysAhead: 3),
                startTime: "10:00 AM",
                endTime: "12:00 PM",
                minAge: 3,
                maxAge: 6,
                category: .outdoors,
                attendingFamilyCount: 12,
                isFeatured: true
            ),
            Event(
                id: "evt-1",
                title: "Toddler Soccer Meetup",
                location: "Riverside Fields",
                date: date(daysAhead: 5),
                startTime: "9:00 AM",
                endTime: "11:00 AM",
                minAge: 3,
                maxAge: 5,
                category: .sports,
                attendingFamilyCount: 5,
                isFeatured: false
            ),
            Event(
                id: "evt-2",
                title: "Storytelling in the Garden",
                location: "Botanical Gardens",
                date: date(daysAhead: 8),
                startTime: "2:00 PM",
                endTime: "3:30 PM",
                minAge: 2,
                maxAge: 8,
                category: .storytime,
                attendingFamilyCount: 8,
                isFeatured: false
            ),
            Event(
                id: "evt-3",
                title: "Arts & Crafts Morning",
                location: "Community Center",
                date: date(daysAhead: 13),
                startTime: "10:00 AM",
                endTime: "12:00 PM",
                minAge: 4,
                maxAge: 8,
                category: .arts,
                attendingFamilyCount: 6,
                isFeatured: false
            ),
            Event(
                id: "evt-4",
                title: "Music & Movement Class",
                location: "Harmony Studio",
                date: date(daysAhead: 15),
                startTime: "4:00 PM",
                endTime: "5:00 PM",
                minAge: 2,
                maxAge: 4,
                category: .music,
                attendingFamilyCount: 4,
                isFeatured: false
            ),
            Event(
                id: "evt-5",
                title: "Family Hike Adventure",
                location: "Greenwood Trail",
                date: date(daysAhead: 18),
                startTime: "8:00 AM",
                endTime: "11:00 AM",
                minAge: 5,
                maxAge: 12,
                category: .outdoors,
                attendingFamilyCount: 9,
                isFeatured: false
            )
        ]
    }()
}
