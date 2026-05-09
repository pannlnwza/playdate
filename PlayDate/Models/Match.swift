import Foundation

struct Match: Codable, Identifiable {
    let id: String
    let userIds: [String]
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         userIds: [String],
         createdAt: Date = Date()) {
        self.id = id
        self.userIds = userIds
        self.createdAt = createdAt
    }
}
