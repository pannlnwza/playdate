import Foundation

struct Child: Codable, Identifiable {
    let id: String
    let parentId: String
    var name: String
    var age: Int
    var bio: String?
    var hobbies: [String]
    var imageUrls: [String]

    var parentName: String?
    var parentVerified: Bool
    var distanceKm: Double?

    init(id: String = UUID().uuidString,
         parentId: String,
         name: String,
         age: Int,
         bio: String? = nil,
         hobbies: [String] = [],
         imageUrls: [String] = [],
         parentName: String? = nil,
         parentVerified: Bool = false,
         distanceKm: Double? = nil) {
        self.id = id
        self.parentId = parentId
        self.name = name
        self.age = age
        self.bio = bio
        self.hobbies = hobbies
        self.imageUrls = imageUrls
        self.parentName = parentName
        self.parentVerified = parentVerified
        self.distanceKm = distanceKm
    }

    var interests: [String] { hobbies }
}
