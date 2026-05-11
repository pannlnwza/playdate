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
    var matchesCount: Int
    var playdatesCount: Int
    var rating: Double
    var reviews: [Review]
    var badges: [Badge]

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let sum = reviews.reduce(0) { $0 + Double($1.rating) }
        return sum / Double(reviews.count)
    }

    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         profileImageUrl: String? = nil,
         isVerified: Bool = false,
         bio: String? = nil,
         childrenIds: [String] = [],
         location: String? = nil,
         matchesCount: Int = 0,
         playdatesCount: Int = 0,
         rating: Double = 0,
         reviews: [Review] = [],
         badges: [Badge] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.isVerified = isVerified
        self.bio = bio
        self.childrenIds = childrenIds
        self.location = location
        self.matchesCount = matchesCount
        self.playdatesCount = playdatesCount
        self.rating = rating
        self.reviews = reviews
        self.badges = badges
    }
}
