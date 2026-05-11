import Foundation

struct Review: Codable, Identifiable {
    let id: String
    let reviewerId: String
    let rating: Int // 1 to 5
    let comment: String
    let timestamp: Date

    init(id: String = UUID().uuidString,
         reviewerId: String,
         rating: Int,
         comment: String,
         timestamp: Date = Date()) {
        self.id = id
        self.reviewerId = reviewerId
        self.rating = rating
        self.comment = comment
        self.timestamp = timestamp
    }
}
