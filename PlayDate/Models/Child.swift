import Foundation

struct Child: Identifiable, Codable, Hashable {
    let id: String
    var parentName: String
    var parentVerified: Bool
    var name: String
    var age: Int
    var bio: String
    var distanceKm: Double
    var interests: [String]
}
