import Foundation

extension ChatMessage {
    static func mockMessages(for sessionId: String) -> [ChatMessage] {
        let cal = Calendar.current
        let now = Date()
        func ago(_ minutes: Int) -> Date { cal.date(byAdding: .minute, value: -minutes, to: now) ?? now }
        let me = "user-current"

        switch sessionId {
        case "c-1":
            return [
                ChatMessage(senderId: "p1", content: "Hi! Saw we matched 🎉 Emma loves outdoor play.", timestamp: ago(180)),
                ChatMessage(senderId: me, content: "Hi Sarah! Great to connect. We're free this weekend if that works?", timestamp: ago(170)),
                ChatMessage(senderId: "p1", content: "Saturday morning would be perfect. Any park you prefer?", timestamp: ago(60)),
                ChatMessage(senderId: me, content: "How about the park near Oak Street? Easy parking and a nice play area.", timestamp: ago(15)),
                ChatMessage(senderId: "p1", content: "That sounds perfect! How about the park near Oak Street? Emma loves the swings there", timestamp: ago(2))
            ]
        case "c-2":
            return [
                ChatMessage(senderId: me, content: "Hi Jessica! Lily would love to meet Olivia.", timestamp: ago(120)),
                ChatMessage(senderId: "p3", content: "Yes! Let's plan something this weekend.", timestamp: ago(110)),
                ChatMessage(senderId: "p3", content: "We're bringing snacks! Olivia is so excited to meet your little one", timestamp: ago(60))
            ]
        case "c-3":
            return [
                ChatMessage(senderId: "p2", content: "Thanks for the playdate yesterday! Noah had a blast", timestamp: ago(180))
            ]
        case "c-4":
            return [
                ChatMessage(senderId: "p4", content: "Are you going to the soccer meetup next week?", timestamp: ago(1440))
            ]
        case "c-5":
            return [
                ChatMessage(senderId: "p5", content: "The art class was wonderful, thank you for recommending it!", timestamp: ago(2880))
            ]
        default:
            return []
        }
    }
}
