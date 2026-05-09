import Foundation

extension Conversation {
    static let mockConversations: [Conversation] = {
        let cal = Calendar.current
        let now = Date()
        func minutesAgo(_ m: Int) -> Date { cal.date(byAdding: .minute, value: -m, to: now) ?? now }
        func hoursAgo(_ h: Int) -> Date { cal.date(byAdding: .hour, value: -h, to: now) ?? now }
        func daysAgo(_ d: Int) -> Date { cal.date(byAdding: .day, value: -d, to: now) ?? now }

        return [
            Conversation(
                id: "c-1",
                parentName: "Sarah M.",
                childContext: "(Emma's mom)",
                lastMessage: "That sounds perfect! How about the park near Oak Street? Emma loves the swings there",
                lastMessageTime: minutesAgo(2),
                unreadCount: 2,
                isOnline: true,
                isNewMatch: true
            ),
            Conversation(
                id: "c-2",
                parentName: "Jessica L.",
                childContext: "(Olivia's mom)",
                lastMessage: "We're bringing snacks! Olivia is so excited to meet your little one",
                lastMessageTime: hoursAgo(1),
                unreadCount: 1,
                isOnline: true,
                isNewMatch: true
            ),
            Conversation(
                id: "c-3",
                parentName: "David R.",
                childContext: "(Noah's dad)",
                lastMessage: "Thanks for the playdate yesterday! Noah had a blast",
                lastMessageTime: hoursAgo(3),
                unreadCount: 0,
                isOnline: false,
                isNewMatch: false
            ),
            Conversation(
                id: "c-4",
                parentName: "Mike T.",
                childContext: "(Liam's dad)",
                lastMessage: "Are you going to the soccer meetup next week?",
                lastMessageTime: daysAgo(1),
                unreadCount: 0,
                isOnline: false,
                isNewMatch: false
            ),
            Conversation(
                id: "c-5",
                parentName: "Anna K.",
                childContext: "(Sophie's mom)",
                lastMessage: "The art class was wonderful, thank you for recommending it!",
                lastMessageTime: daysAgo(2),
                unreadCount: 0,
                isOnline: false,
                isNewMatch: false
            )
        ]
    }()
}
