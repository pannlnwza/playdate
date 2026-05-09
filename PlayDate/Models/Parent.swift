import Foundation

struct Parent: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var profileImageUrl: String?
    var isVerified: Bool
    var bio: String?
    var childrenIds: [String]
    
    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         profileImageUrl: String? = nil,
         isVerified: Bool = false,
         bio: String? = nil,
         childrenIds: [String] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.isVerified = isVerified
        self.bio = bio
        self.childrenIds = childrenIds
    }
}
