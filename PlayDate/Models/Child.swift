import Foundation

struct Child: Codable, Identifiable {
    let id: String
    let parentId: String
    var name: String
    var age: Int
    var bio: String?
    var hobbies: [String]
    var imageUrls: [String]
    
    init(id: String = UUID().uuidString,
         parentId: String,
         name: String,
         age: Int,
         bio: String? = nil,
         hobbies: [String] = [],
         imageUrls: [String] = []) {
        self.id = id
        self.parentId = parentId
        self.name = name
        self.age = age
        self.bio = bio
        self.hobbies = hobbies
        self.imageUrls = imageUrls
    }
}
