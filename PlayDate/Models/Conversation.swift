import Foundation

struct Conversation: Identifiable, Codable, Hashable {
    let id: String
    var parentName: String
    var childContext: String
    var lastMessage: String
    var lastMessageTime: Date
    var unreadCount: Int
    var isOnline: Bool
    var isNewMatch: Bool
}
