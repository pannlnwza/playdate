import Foundation

struct ChatSession: Codable, Identifiable, Hashable {
    let id: String
    let participantIds: [String]
    var lastMessage: String?
    var lastMessageTimestamp: Date?

    var participantNames: [String: String]
    var participantImageUrls: [String: String]
    var participantChildIds: [String: String]

    var parentName: String?
    var parentImageUrl: String?
    var childId: String?
    var childContext: String?
    var unreadCount: Int
    var isOnline: Bool
    var isNewMatch: Bool

    init(id: String = UUID().uuidString,
         participantIds: [String],
         lastMessage: String? = nil,
         lastMessageTimestamp: Date? = nil,
         participantNames: [String: String] = [:],
         participantImageUrls: [String: String] = [:],
         participantChildIds: [String: String] = [:],
         parentName: String? = nil,
         parentImageUrl: String? = nil,
         childId: String? = nil,
         childContext: String? = nil,
         unreadCount: Int = 0,
         isOnline: Bool = false,
         isNewMatch: Bool = false) {
        self.id = id
        self.participantIds = participantIds
        self.lastMessage = lastMessage
        self.lastMessageTimestamp = lastMessageTimestamp
        self.participantNames = participantNames
        self.participantImageUrls = participantImageUrls
        self.participantChildIds = participantChildIds
        self.parentName = parentName
        self.parentImageUrl = parentImageUrl
        self.childId = childId
        self.childContext = childContext
        self.unreadCount = unreadCount
        self.isOnline = isOnline
        self.isNewMatch = isNewMatch
    }

    var lastMessageTime: Date? { lastMessageTimestamp }

    func otherParticipantId(currentUserId: String) -> String? {
        participantIds.first { $0 != currentUserId }
    }

    func otherName(currentUserId: String) -> String? {
        if let other = otherParticipantId(currentUserId: currentUserId),
           let name = participantNames[other], !name.isEmpty {
            return name
        }
        return parentName
    }

    func otherImageUrl(currentUserId: String) -> String? {
        if let other = otherParticipantId(currentUserId: currentUserId),
           let url = participantImageUrls[other], !url.isEmpty {
            return url
        }
        return parentImageUrl
    }

    func childIdForCurrentUser(_ currentUserId: String) -> String? {
        participantChildIds[currentUserId] ?? childId
    }
}

typealias Conversation = ChatSession
