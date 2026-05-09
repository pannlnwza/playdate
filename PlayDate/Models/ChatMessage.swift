import Foundation

enum MessageType: String, Codable {
    case text
    case sticker
    case voiceNote
}

struct ChatMessage: Codable, Identifiable {
    let id: String
    let senderId: String
    let content: String
    let timestamp: Date
    let type: MessageType
    
    init(id: String = UUID().uuidString,
         senderId: String,
         content: String,
         timestamp: Date = Date(),
         type: MessageType = .text) {
        self.id = id
        self.senderId = senderId
        self.content = content
        self.timestamp = timestamp
        self.type = type
    }
}
