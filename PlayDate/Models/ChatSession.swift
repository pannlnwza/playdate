import Foundation

struct ChatSession: Codable, Identifiable {
    let id: String
    let participantIds: [String]
    var lastMessage: String?
    var lastMessageTimestamp: Date?

    var parentName: String?
    var childContext: String?
    var unreadCount: Int
    var isOnline: Bool
    var isNewMatch: Bool

    init(id: String = UUID().uuidString,
         participantIds: [String],
         lastMessage: String? = nil,
         lastMessageTimestamp: Date? = nil,
         parentName: String? = nil,
         childContext: String? = nil,
         unreadCount: Int = 0,
         isOnline: Bool = false,
         isNewMatch: Bool = false) {
        self.id = id
        self.participantIds = participantIds
        self.lastMessage = lastMessage
        self.lastMessageTimestamp = lastMessageTimestamp
        self.parentName = parentName
        self.childContext = childContext
        self.unreadCount = unreadCount
        self.isOnline = isOnline
        self.isNewMatch = isNewMatch
    }

    var lastMessageTime: Date? { lastMessageTimestamp }
}

typealias Conversation = ChatSession
