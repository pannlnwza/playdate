import Foundation

extension AppNotification {
    static let mockNotifications: [AppNotification] = {
        let cal = Calendar.current
        let now = Date()
        func ago(_ minutes: Int) -> Date { cal.date(byAdding: .minute, value: -minutes, to: now) ?? now }

        return [
            AppNotification(
                id: "n1",
                kind: .match,
                title: "It's a PlayDate!",
                body: "Sarah swiped right on Lily — say hello!",
                timestamp: ago(5),
                isRead: false,
                iconName: "heart.fill"
            ),
            AppNotification(
                id: "n2",
                kind: .message,
                title: "New message from Sarah M.",
                body: "That sounds perfect! How about the park near Oak Street?",
                timestamp: ago(45),
                isRead: false,
                iconName: "message.fill"
            ),
            AppNotification(
                id: "n3",
                kind: .match,
                title: "New match",
                body: "Jessica L. wants Olivia and Lily to play together",
                timestamp: ago(120),
                isRead: false,
                iconName: "heart.fill"
            ),
            AppNotification(
                id: "n4",
                kind: .eventReminder,
                title: "Upcoming event",
                body: "Park Picnic Playdate is in 2 days",
                timestamp: ago(240),
                isRead: true,
                iconName: "calendar"
            ),
            AppNotification(
                id: "n5",
                kind: .event,
                title: "New event nearby",
                body: "Toddler Soccer Meetup at Riverside Fields",
                timestamp: ago(720),
                isRead: true,
                iconName: "calendar.badge.plus"
            )
        ]
    }()
}
