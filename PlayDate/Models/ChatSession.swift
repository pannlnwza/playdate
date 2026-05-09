import Foundation

struct ChatSession: Codable, Identifiable {
    let id: String
    let participantIds: [String]
    var lastMessage: String?
    var lastMessageTimestamp: Date?
    
    init(id: String = UUID().uuidString,
         participantIds: [String],
         lastMessage: String? = nil,
         lastMessageTimestamp: Date? = nil) {
        self.id = id
        self.participantIds = participantIds
        self.lastMessage = lastMessage
        self.lastMessageTimestamp = lastMessageTimestamp
    }
}
