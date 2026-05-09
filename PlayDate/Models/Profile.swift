import Foundation

struct Profile: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var location: String
    var isVerified: Bool
    var matchesCount: Int
    var playdatesCount: Int
    var rating: Double
    var children: [ProfileChild]
}

struct ProfileChild: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var age: Int
    var interests: [String]
}
