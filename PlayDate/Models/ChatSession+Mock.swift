import Foundation

extension ChatSession {
    static let mockSessions: [ChatSession] = {
        let cal = Calendar.current
        let now = Date()
        func minutesAgo(_ m: Int) -> Date { cal.date(byAdding: .minute, value: -m, to: now) ?? now }
        func hoursAgo(_ h: Int) -> Date { cal.date(byAdding: .hour, value: -h, to: now) ?? now }
        func daysAgo(_ d: Int) -> Date { cal.date(byAdding: .day, value: -d, to: now) ?? now }

        return [
            ChatSession(
                id: "c-1",
                participantIds: ["user-current", "p1"],
                lastMessage: "That sounds perfect! How about the park near Oak Street? Emma loves the swings there",
                lastMessageTimestamp: minutesAgo(2),
                parentName: "Sarah M.",
                childContext: "(Emma's mom)",
                unreadCount: 2,
                isOnline: true,
                isNewMatch: true
            ),
            ChatSession(
                id: "c-2",
                participantIds: ["user-current", "p3"],
                lastMessage: "We're bringing snacks! Olivia is so excited to meet your little one",
                lastMessageTimestamp: hoursAgo(1),
                parentName: "Jessica L.",
                childContext: "(Olivia's mom)",
                unreadCount: 1,
                isOnline: true,
                isNewMatch: true
            ),
            ChatSession(
                id: "c-3",
                participantIds: ["user-current", "p2"],
                lastMessage: "Thanks for the playdate yesterday! Noah had a blast",
                lastMessageTimestamp: hoursAgo(3),
                parentName: "David R.",
                childContext: "(Noah's dad)"
            ),
            ChatSession(
                id: "c-4",
                participantIds: ["user-current", "p4"],
                lastMessage: "Are you going to the soccer meetup next week?",
                lastMessageTimestamp: daysAgo(1),
                parentName: "Mike T.",
                childContext: "(Liam's dad)"
            ),
            ChatSession(
                id: "c-5",
                participantIds: ["user-current", "p5"],
                lastMessage: "The art class was wonderful, thank you for recommending it!",
                lastMessageTimestamp: daysAgo(2),
                parentName: "Anna K.",
                childContext: "(Sophie's mom)"
            )
        ]
    }()

    static var mockConversations: [ChatSession] { mockSessions }
}
