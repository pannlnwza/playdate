import Foundation

struct Parent: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var profileImageUrl: String?
    var isVerified: Bool
    var bio: String?
    var childrenIds: [String]

    var location: String?
    var latitude: Double?
    var longitude: Double?
    var matchesCount: Int
    var playdatesCount: Int
    var rating: Double

    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         profileImageUrl: String? = nil,
         isVerified: Bool = false,
         bio: String? = nil,
         childrenIds: [String] = [],
         location: String? = nil,
         latitude: Double? = nil,
         longitude: Double? = nil,
         matchesCount: Int = 0,
         playdatesCount: Int = 0,
         rating: Double = 0) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.isVerified = isVerified
        self.bio = bio
        self.childrenIds = childrenIds
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.matchesCount = matchesCount
        self.playdatesCount = playdatesCount
        self.rating = rating
    }
}
